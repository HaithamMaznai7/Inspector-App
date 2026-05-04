import 'dart:async';
import 'dart:typed_data';

import 'package:fahis_inspector/obd_ble/transport/obd_transport.dart';
import 'package:fahis_inspector/obd_ble/util/obd_logger.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE GATT transport for ELM327 OBD-II adapters that expose the ISSC BT5050
/// dual-channel service (e.g. Veepeak OBDCheck BLE on iOS).
///
/// Service / characteristic UUIDs are baked in because every BT5050-based
/// adapter on the market ships with the same identifiers — they're a fixed
/// part of the vendor stack, not something the chip exposes for per-device
/// customisation. UUIDs were verified against a real Veepeak OBDCheck BLE
/// using nRF Connect on iPhone.
///
/// Why two notify subscriptions: the BT5050 datasheet documents notifications
/// on the dedicated RX characteristic (`ACA3`), but a number of clone units
/// in the field surface their responses on the TX characteristic (`6DAA`)
/// instead. Subscribing to both and merging the streams covers either layout
/// without the inspector having to know which silicon revision they bought.
class BleTransport implements ObdTransport {
  static final Guid _serviceUuid =
      Guid('49535343-fe7d-4ae5-8fa9-9fafd205e455');
  static final Guid _txWriteUuid =
      Guid('49535343-6daa-4d02-abf6-19569aca69fe');
  static final Guid _rxNotifyUuid =
      Guid('49535343-aca3-481c-91ec-d85e28a60318');

  static const Duration _connectTimeout = Duration(seconds: 15);

  BluetoothDevice? _device;
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
    _writeChr = write;
    _notifyChr = notify;
    ObdLogger.info('Matched TX (6DAA) + RX (ACA3) characteristics');

    // Primary RX subscription on the documented notify characteristic. If the
    // adapter is genuinely non-standard and even ACA3 lacks notify/indicate,
    // bail with a precise error instead of letting CoreBluetooth surface its
    // generic `setNotifyValue` PlatformException — that message is hard to
    // act on in the field.
    if (!notify.properties.notify && !notify.properties.indicate) {
      ObdLogger.error(
        'RX (ACA3) does not advertise notify/indicate — adapter is non-standard',
      );
      throw StateError(
        'OBD adapter has no characteristic capable of delivering notifications',
      );
    }
    await notify.setNotifyValue(true);
    _notifySub = notify.lastValueStream
        .where((data) => data.isNotEmpty)
        .listen(_onIncoming, onError: _onTransportError);
    ObdLogger.info('Subscribed notify on RX (ACA3)');

    // Belt-and-suspenders subscription on the write characteristic — only if
    // *this* particular adapter's firmware advertises notify/indicate on it.
    // Some BT5050 clones surface responses on TX; the stock Veepeak does not.
    // CoreBluetooth requires the property bits before `setNotifyValue:` is
    // legal, so we gate strictly on what the chip declares.
    if (write.properties.notify || write.properties.indicate) {
      await write.setNotifyValue(true);
      _writeNotifySub = write.lastValueStream
          .where((data) => data.isNotEmpty)
          .listen(_onIncoming, onError: _onTransportError);
      ObdLogger.info('Subscribed notify on TX (6DAA) — clone fallback active');
    } else {
      ObdLogger.info(
        'TX (6DAA) does not advertise notify/indicate — skipping fallback '
        '(normal for stock Veepeak BT5050)',
      );
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

    AppLogger.log('[OBD BLE]', 'Notifications subscribed on TX + RX');
    ObdLogger.info('Subscribed to notifications on TX + RX');
  }

  @override
  Future<void> write(List<int> data) async {
    final w = _writeChr;
    if (w == null) {
      throw StateError('BLE write characteristic not connected');
    }
    await w.write(data, withoutResponse: true);
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
    final write = _writeChr;
    if (notify != null) {
      try {
        await notify.setNotifyValue(false);
      } catch (_) {}
    }
    if (write != null) {
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
    _writeChr = null;
    _notifyChr = null;
  }

  void _onIncoming(List<int> data) {
    if (_byteController.isClosed) return;
    _byteController.add(Uint8List.fromList(data));
  }

  void _onTransportError(Object error) {
    AppLogger.error('[OBD BLE]', 'Notification stream error', error);
    ObdLogger.error('Notification stream error: $error');
    if (!_byteController.isClosed) {
      _byteController.addError(error);
    }
  }
}
