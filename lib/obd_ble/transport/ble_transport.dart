import 'dart:async';
import 'dart:typed_data';

import 'package:fahis_inspector/obd_ble/transport/obd_ble_write.dart';
import 'package:fahis_inspector/obd_ble/transport/obd_transport.dart';
import 'package:fahis_inspector/obd_ble/util/obd_logger.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE GATT transport for ELM327 OBD-II adapters that expose the ISSC BT5050
/// dual-channel service (e.g. Veepeak OBDCheck BLE on iOS).
///
/// ## BT5050 UART write-type quirk (critical for iOS)
/// The BT5050 chip routes data to its ELM327 UART **only** when it receives
/// an ATT Write Command (opcode 0x52 — "Write Without Response").  An ATT
/// Write Request (opcode 0x12 — "Write With Response") is handled entirely
/// inside the BT5050's GATT layer: the chip ACKs it but the data never
/// reaches the UART.  This is documented in the ISSC BT5050 SDK and is the
/// root cause of the iOS "no RECV after ATZ" failure.
///
/// Despite the chip advertising `writeWithoutResponse = false` on both
/// characteristics, we MUST use Write Command.  However, flutter_blue_plus's
/// native iOS layer (`FlutterBluePlusPlugin.m` line 554) validates the
/// property bit and rejects the write before it reaches CoreBluetooth.
/// We bypass this with [ObdBleWrite] — a native Swift plugin that calls
/// CoreBluetooth directly, mirroring how `SppPlugin.kt` bridges Android.
///
/// ## Characteristic roles
///   - TX / 6DAA (`write=true`): host → chip → ELM327 UART (write here).
///   - RX / ACA3 (`notify=true`): ELM327 UART → chip → host (subscribe here).
class BleTransport implements ObdTransport {
  static final Guid _serviceUuid =
      Guid('49535343-fe7d-4ae5-8fa9-9fafd205e455');
  static final Guid _txWriteUuid =
      Guid('49535343-6daa-4d02-abf6-19569aca69fe');
  static final Guid _rxNotifyUuid =
      Guid('49535343-aca3-481c-91ec-d85e28a60318');

  static const Duration _connectTimeout = Duration(seconds: 15);

  BluetoothDevice? _device;
  String? _deviceId;
  BluetoothCharacteristic? _writeChr;
  BluetoothCharacteristic? _notifyChr;

  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<List<int>>? _writeNotifySub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;

  // Marks a `disconnect()` call so the connection-state stream's eventual
  // `disconnected` event isn't surfaced as an unexpected drop to the
  // connection service.
  bool _intentionalDisconnect = false;

  final StreamController<Uint8List> _byteController =
      StreamController<Uint8List>.broadcast();

  @override
  Stream<Uint8List> get byteStream => _byteController.stream;

  @override
  Future<void> connect(String deviceId) async {
    AppLogger.log('[OBD BLE]', 'Connecting to $deviceId');
    ObdLogger.info('BLE connect → $deviceId');
    _intentionalDisconnect = false;

    final device = BluetoothDevice.fromId(deviceId);
    _device = device;
    _deviceId = deviceId;

    try {
      await device.connect(
        timeout: _connectTimeout,
        autoConnect: false,
        license: License.free,
      );
      AppLogger.log('[OBD BLE]', 'GATT link established');
      ObdLogger.info('GATT link established');
    } catch (e) {
      ObdLogger.error('GATT connect failed: $e');
      rethrow;
    }

    // Log negotiated MTU immediately after connect — useful for diagnosing
    // fragmentation issues if responses are ever truncated.
    ObdLogger.info('MTU now: ${device.mtuNow}');

    List<BluetoothService> services;
    try {
      services = await device.discoverServices();
      ObdLogger.info('Discovered ${services.length} services');
    } catch (e) {
      ObdLogger.error('discoverServices failed: $e');
      rethrow;
    }

    final service = services.firstWhere(
      (s) => s.uuid == _serviceUuid,
      orElse: () {
        ObdLogger.error('OBD service $_serviceUuid not found on adapter');
        throw StateError(
          'OBD service $_serviceUuid not found on adapter',
        );
      },
    );
    ObdLogger.info('Matched OBD service $_serviceUuid');

    // Dump every characteristic + its property bits so the next debug
    // iteration is always data-driven.
    for (final c in service.characteristics) {
      final p = c.properties;
      ObdLogger.info(
        'Chr ${c.uuid}: '
        'read=${p.read} write=${p.write} writeNR=${p.writeWithoutResponse} '
        'notify=${p.notify} indicate=${p.indicate} broadcast=${p.broadcast}',
      );
    }

    BluetoothCharacteristic? write;
    BluetoothCharacteristic? notify;
    for (final c in service.characteristics) {
      if (c.uuid == _txWriteUuid) write = c;
      if (c.uuid == _rxNotifyUuid) notify = c;
    }
    if (write == null || notify == null) {
      ObdLogger.error(
        'Missing characteristics — write=${write != null}, notify=${notify != null}',
      );
      throw StateError('OBD characteristics missing on adapter');
    }

    // TX always goes to 6DAA — the BT5050 UART bridge input.
    // RX notifications come from ACA3 — the BT5050 UART bridge output.
    // We never redirect writes to ACA3: even though ACA3 has write=true, a
    // Write Request to it is handled at GATT layer; only Write Commands
    // (withoutResponse) on 6DAA reach the ELM327 UART.
    _writeChr = write;
    _notifyChr = notify;
    ObdLogger.info(
      'TX → 6DAA (Write Command forced, bypasses BT5050 GATT layer to UART) '
      '| RX ← ACA3 (notify)',
    );

    // Guard: ACA3 must have notify or indicate.
    if (!notify.properties.notify && !notify.properties.indicate) {
      ObdLogger.error(
        'RX (ACA3) does not advertise notify/indicate — adapter is non-standard',
      );
      throw StateError(
        'OBD adapter has no characteristic capable of delivering notifications',
      );
    }
    await notify.setNotifyValue(true);
    ObdLogger.info(
      'Subscribed notify on RX (ACA3) — isNotifying=${notify.isNotifying}',
    );

    _notifySub = notify.onValueReceived
        .where((data) => data.isNotEmpty)
        .listen(_onIncoming, onError: _onTransportError);

    // Belt-and-suspenders: some BT5050 clone units surface responses on TX
    // (6DAA) via notify instead of ACA3.  Subscribe only if the property
    // is present — CoreBluetooth rejects setNotifyValue on a characteristic
    // without notify/indicate.
    if (write.properties.notify || write.properties.indicate) {
      await write.setNotifyValue(true);
      _writeNotifySub = write.onValueReceived
          .where((data) => data.isNotEmpty)
          .listen(_onIncoming, onError: _onTransportError);
      ObdLogger.info('Subscribed notify on TX (6DAA) — clone fallback active');
    } else {
      ObdLogger.info('TX (6DAA) has no notify/indicate — clone fallback skipped');
    }

    _connStateSub = device.connectionState.listen((state) {
      AppLogger.log('[OBD BLE]', 'Conn state: $state');
      ObdLogger.info('BLE conn state: $state');
      if (state == BluetoothConnectionState.disconnected &&
          !_intentionalDisconnect &&
          !_byteController.isClosed) {
        ObdLogger.warn('Unexpected BLE disconnect — surfacing as stream error');
        _byteController.addError(StateError('BLE link disconnected'));
      }
    });

    AppLogger.log('[OBD BLE]', 'Notification subscriptions active');

    // Prepare the native write bridge.  This creates its own CBCentralManager,
    // retrieves the same physical peripheral, discovers the service +
    // characteristic, and caches the CBCharacteristic for direct writes that
    // bypass flutter_blue_plus's writeNR property validation.
    try {
      await ObdBleWrite.prepare(
        remoteId: deviceId,
        serviceUuid: _serviceUuid.str,
        characteristicUuid: _txWriteUuid.str,
      );
      ObdLogger.info(
        'Native write bridge ready — WriteCommand/withoutResponse forced on '
        '$_txWriteUuid (BT5050 UART quirk — bypasses FBP property validation)',
      );
    } catch (e) {
      ObdLogger.error('Native write bridge prepare failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> write(List<int> data) async {
    if (_deviceId == null) {
      throw StateError('BLE write characteristic not connected');
    }
    // Write via the native bridge which calls CoreBluetooth directly with
    // CBCharacteristicWriteWithoutResponse — bypassing flutter_blue_plus's
    // native property validation that would reject writeNR on a
    // characteristic that doesn't advertise the property.
    try {
      await ObdBleWrite.writeWithoutResponse(Uint8List.fromList(data));
    } catch (e) {
      ObdLogger.error('BLE write failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    AppLogger.log('[OBD BLE]', 'Disconnect requested');
    ObdLogger.info('BLE disconnect requested');
    _intentionalDisconnect = true;

    await _notifySub?.cancel();
    _notifySub = null;
    await _writeNotifySub?.cancel();
    _writeNotifySub = null;
    await _connStateSub?.cancel();
    _connStateSub = null;

    final notify = _notifyChr;
    if (notify != null) {
      try {
        await notify.setNotifyValue(false);
      } catch (_) {}
    }

    final write = _writeChr;
    if (write != null &&
        (write.properties.notify || write.properties.indicate)) {
      try {
        await write.setNotifyValue(false);
      } catch (_) {}
    }

    // Tear down the native write bridge (releases the secondary
    // CBCentralManager link and cached characteristic).
    try {
      await ObdBleWrite.dispose();
    } catch (_) {}

    final device = _device;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (_) {}
    }

    _device = null;
    _deviceId = null;
    _writeChr = null;
    _notifyChr = null;
  }

  void _onIncoming(List<int> data) {
    if (_byteController.isClosed) return;
    // Log every raw notification chunk at transport level so we can see BLE
    // fragments before they are concatenated by the command service.
    ObdLogger.recv(
      'BLE chunk (${data.length}B): '
      'hex=${_hex(data)} ascii="${_ascii(data)}"',
    );
    _byteController.add(Uint8List.fromList(data));
  }

  void _onTransportError(Object error) {
    AppLogger.error('[OBD BLE]', 'Notification stream error', error);
    ObdLogger.error('Notification stream error: $error');
    if (!_byteController.isClosed) {
      _byteController.addError(error);
    }
  }

  static String _hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  static String _ascii(List<int> bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      if (b == 0x0D) {
        sb.write(r'\r');
      } else if (b == 0x0A) {
        sb.write(r'\n');
      } else if (b >= 0x20 && b <= 0x7E) {
        sb.writeCharCode(b);
      } else {
        sb.write('\\x${b.toRadixString(16).padLeft(2, '0')}');
      }
    }
    return sb.toString();
  }
}
