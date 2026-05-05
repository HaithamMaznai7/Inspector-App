import 'dart:async';
import 'dart:typed_data';

import 'package:fahis_inspector/obd_ble/transport/obd_transport.dart';
import 'package:fahis_inspector/obd_ble/util/obd_logger.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE GATT transport for ELM327 OBD-II adapters that expose the generic
/// `FFF0` UART bridge (Veepeak OBDCheck BLE and most cheap iOS-friendly
/// ELM327 BLE clones).
///
/// ## Why FFF0, not the ISSC service
/// The Veepeak OBDCheck BLE (BT5050 chip) advertises **two** services on iOS:
///   - `49535343-FE7D-...` — the BT5050's own ISSC Transparent UART. Writes
///     here reach the radio chip but are *not* bridged to the ELM327 MCU
///     behind it, so the chip silently drops every byte. Reproduced with
///     nRF Connect: ATZ\r writes succeed at the GATT layer but no notify
///     ever fires. This is why earlier attempts targeting ACA3/6DAA always
///     produced zero RECV.
///   - `FFF0` — the actual OBD bridge service. Same triple used by every
///     known-working iOS OBD library (SwiftOBD2, obd-ble-serial,
///     DauntlessOBD, LTSupportAutomotive) and by Car Scanner / OBD Fusion.
///
/// ## Characteristic roles on FFF0
///   - `FFF1` — notify only (RX): subscribe here for ELM327 responses.
///   - `FFF2` — write (TX): write `<cmd>\r` here.
///
/// flutter_blue_plus handles both writeWithResponse and writeWithoutResponse
/// natively on these characteristics — the native `ObdBleWritePlugin` bypass
/// that was needed for the BT5050 ISSC quirk is *not* needed here and is no
/// longer used on the iOS path.
class BleTransport implements ObdTransport {
  static final Guid _serviceUuid =
      Guid('0000fff0-0000-1000-8000-00805f9b34fb');

  /// FFF1 — notify-only RX characteristic.
  static final Guid _rxUuid =
      Guid('0000fff1-0000-1000-8000-00805f9b34fb');

  /// FFF2 — write-only TX characteristic.
  static final Guid _txUuid =
      Guid('0000fff2-0000-1000-8000-00805f9b34fb');

  static const Duration _connectTimeout = Duration(seconds: 15);

  BluetoothDevice? _device;
  BluetoothCharacteristic? _txChr;
  BluetoothCharacteristic? _rxChr;

  // Cached at connect-time so the per-write hot path doesn't re-read the
  // property bits.
  bool _useWithoutResponse = false;

  StreamSubscription<List<int>>? _rxSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;

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

    for (final c in service.characteristics) {
      final p = c.properties;
      ObdLogger.info(
        'Chr ${c.uuid}: '
        'read=${p.read} write=${p.write} writeNR=${p.writeWithoutResponse} '
        'notify=${p.notify} indicate=${p.indicate} broadcast=${p.broadcast}',
      );
    }

    BluetoothCharacteristic? tx;
    BluetoothCharacteristic? rx;
    for (final c in service.characteristics) {
      if (c.uuid == _txUuid) tx = c;
      if (c.uuid == _rxUuid) rx = c;
    }
    if (tx == null) {
      ObdLogger.error('TX characteristic FFF2 not found — adapter is non-standard');
      throw StateError('OBD TX characteristic FFF2 missing on adapter');
    }
    if (rx == null) {
      ObdLogger.error('RX characteristic FFF1 not found — adapter is non-standard');
      throw StateError('OBD RX characteristic FFF1 missing on adapter');
    }
    if (!tx.properties.write && !tx.properties.writeWithoutResponse) {
      ObdLogger.error('FFF2 advertises no write capability — cannot send commands');
      throw StateError('OBD TX characteristic has no write capability');
    }
    if (!rx.properties.notify && !rx.properties.indicate) {
      ObdLogger.error('FFF1 advertises no notify/indicate — cannot receive responses');
      throw StateError('OBD RX characteristic has no notify capability');
    }

    _txChr = tx;
    _rxChr = rx;

    // Match SwiftOBD2's behaviour: prefer Write Request (with response)
    // when the characteristic supports it, fall back to Write Command
    // only if it's the only option.  Tested across BT5050 / OBDCheck BLE
    // firmware revs.
    _useWithoutResponse =
        tx.properties.writeWithoutResponse && !tx.properties.write;

    ObdLogger.info(
      'TX → FFF2 (writeWithoutResponse=$_useWithoutResponse) '
      '| RX ← FFF1 (notify)',
    );

    await rx.setNotifyValue(true);
    ObdLogger.info('Subscribed notify on FFF1 — isNotifying=${rx.isNotifying}');

    _rxSub = rx.onValueReceived
        .where((data) => data.isNotEmpty)
        .listen(_onIncoming, onError: _onTransportError);

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
    final tx = _txChr;
    if (tx == null) {
      throw StateError('BLE write characteristic not connected');
    }
    try {
      await tx.write(data, withoutResponse: _useWithoutResponse);
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

    await _rxSub?.cancel();
    _rxSub = null;
    await _connStateSub?.cancel();
    _connStateSub = null;

    final rx = _rxChr;
    if (rx != null) {
      try {
        await rx.setNotifyValue(false);
      } catch (_) {}
    }

    final device = _device;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (_) {}
    }

    _device = null;
    _txChr = null;
    _rxChr = null;
  }

  void _onIncoming(List<int> data) {
    if (_byteController.isClosed) return;
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
