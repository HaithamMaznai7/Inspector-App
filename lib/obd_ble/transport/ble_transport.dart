import 'dart:async';
import 'dart:typed_data';

import 'package:fahis_inspector/obd_ble/transport/obd_transport.dart';
import 'package:fahis_inspector/obd_ble/util/obd_logger.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE GATT transport for ELM327 OBD-II adapters that expose the ISSC BT5050
/// dual-channel service (e.g. Veepeak OBDCheck BLE on iOS).
///
/// ## Characteristic roles
///   - ACA3 (`write=true, notify=true`): bidirectional — host writes here
///     AND subscribes for ELM327 responses here.
///   - 6DAA (`write=true, notify=false`): secondary — some clone adapters may
///     surface responses on this characteristic; we subscribe if it has notify.
class BleTransport implements ObdTransport {
  static final Guid _serviceUuid =
      Guid('49535343-fe7d-4ae5-8fa9-9fafd205e455');
  /// ACA3 — bidirectional: write commands here AND receive notifications here.
  static final Guid _aca3Uuid =
      Guid('49535343-aca3-481c-91ec-d85e28a60318');
  /// 6DAA — secondary write-only characteristic (fallback notify for clones).
  static final Guid _6daaUuid =
      Guid('49535343-6daa-4d02-abf6-19569aca69fe');

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

    BluetoothCharacteristic? aca3;
    BluetoothCharacteristic? daa6;
    for (final c in service.characteristics) {
      if (c.uuid == _aca3Uuid) aca3 = c;
      if (c.uuid == _6daaUuid) daa6 = c;
    }
    if (aca3 == null) {
      ObdLogger.error('ACA3 characteristic not found — cannot communicate');
      throw StateError('OBD ACA3 characteristic missing on adapter');
    }

    // ACA3 is bidirectional: write commands here AND receive notifications.
    // Previous attempts writing to 6DAA (both WriteWithResponse and
    // WriteWithoutResponse) produced zero RECV.  ACA3 is the correct
    // write target for the ISSC UART bridge.
    _writeChr = aca3;
    _notifyChr = aca3;
    ObdLogger.info(
      'TX → ACA3 (WriteWithResponse, bidirectional) '
      '| RX ← ACA3 (notify)',
    );

    // Guard: ACA3 must have notify or indicate.
    if (!aca3.properties.notify && !aca3.properties.indicate) {
      ObdLogger.error(
        'ACA3 does not advertise notify/indicate — adapter is non-standard',
      );
      throw StateError(
        'OBD adapter has no characteristic capable of delivering notifications',
      );
    }
    await aca3.setNotifyValue(true);
    ObdLogger.info(
      'Subscribed notify on ACA3 — isNotifying=${aca3.isNotifying}',
    );

    _notifySub = aca3.onValueReceived
        .where((data) => data.isNotEmpty)
        .listen(_onIncoming, onError: _onTransportError);

    // Belt-and-suspenders: some BT5050 clone units surface responses on
    // 6DAA via notify instead of ACA3.  Subscribe only if the property
    // is present — CoreBluetooth rejects setNotifyValue on a characteristic
    // without notify/indicate.
    if (daa6 != null &&
        (daa6.properties.notify || daa6.properties.indicate)) {
      await daa6.setNotifyValue(true);
      _writeNotifySub = daa6.onValueReceived
          .where((data) => data.isNotEmpty)
          .listen(_onIncoming, onError: _onTransportError);
      ObdLogger.info('Subscribed notify on 6DAA — clone fallback active');
    } else {
      ObdLogger.info('6DAA has no notify/indicate — clone fallback skipped');
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

  }

  @override
  Future<void> write(List<int> data) async {
    final chr = _writeChr;
    if (chr == null) {
      throw StateError('BLE write characteristic not connected');
    }
    // Write to ACA3 with WriteWithResponse (the default for write=true).
    // flutter_blue_plus handles this natively — no native plugin needed.
    try {
      await chr.write(Uint8List.fromList(data), withoutResponse: false);
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
