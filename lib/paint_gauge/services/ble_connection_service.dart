import 'dart:async';

import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Connection state exposed to consumers.
enum BleConnectionState {
  disconnected,
  connecting,
  connected,
  error,

  /// Device dropped the link unexpectedly (e.g. LINK_SUPERVISION_TIMEOUT).
  /// Distinct from [disconnected] which is user-initiated via [disconnect()].
  lostConnection,
}

/// Encapsulates the full BLE lifecycle: connect, discover, subscribe, write, disconnect.
///
/// Specifically targets the Guoou paint gauge protocol (FFE0/FFE1),
/// but falls back to any NOTIFY/WRITE characteristic if FFE1 isn't found.
class BleConnectionService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _notifyChar;
  BluetoothCharacteristic? _writeChar;
  final List<StreamSubscription<List<int>>> _subscriptions = [];

  // true while the user has explicitly called disconnect() — prevents
  // the device.connectionState listener from treating it as a lost link.
  bool _intentionalDisconnect = false;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSub;

  final _stateController = StreamController<BleConnectionState>.broadcast();
  final _dataController = StreamController<List<int>>.broadcast();

  /// Stream of connection state changes.
  Stream<BleConnectionState> get connectionState => _stateController.stream;

  /// Stream of incoming BLE notification data (raw bytes).
  Stream<List<int>> get notifications => _dataController.stream;

  /// Whether a write characteristic is available.
  bool get canWrite => _writeChar != null;

  /// Current connection state snapshot.
  BleConnectionState _currentState = BleConnectionState.disconnected;
  BleConnectionState get currentState => _currentState;

  /// Connects to device, negotiates MTU, discovers services, subscribes to notifications.
  Future<void> connect(String deviceId) async {
    _setState(BleConnectionState.connecting);

    try {
      _device = BluetoothDevice.fromId(deviceId);
      AppLogger.log('Connecting to $deviceId', 'Attempting BLE connection');

      await _device!
          .connect(timeout: const Duration(seconds: 15), license: License.free)
          .catchError((e) {
            AppLogger.error('Connection error', e);
            throw e;
          });

      AppLogger.log(
        'Connected successfully',
        'Device: ${_device!.platformName}',
      );

      // MTU negotiation (non-critical)
      try {
        await _device!.requestMtu(247);
        AppLogger.log(
          'MTU set to 247',
          'MTU negotiation completed successfully',
        );
      } catch (e) {
        AppLogger.log(
          'MTU request failed (not critical): $e',
          'MTU negotiation failed',
        );
      }

      // Service discovery
      final services = await _device!.discoverServices();
      AppLogger.log(
        'Found ${services.length} services',
        'Service discovery completed',
      );

      _logServices(services);
      _findCharacteristics(services);

      if (_notifyChar == null) {
        AppLogger.error(
          'No NOTIFY characteristic found',
          'Cannot subscribe to notifications',
        );
        _setState(BleConnectionState.error);
        return;
      }

      // Watch for unexpected disconnects (e.g. LINK_SUPERVISION_TIMEOUT)
      _connectionStateSub = _device!.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected &&
            !_intentionalDisconnect &&
            _currentState == BleConnectionState.connected) {
          AppLogger.log(
            'Device dropped connection unexpectedly',
            'Detected lost connection',
          );
          _notifyChar = null;
          _writeChar = null;
          _setState(BleConnectionState.lostConnection);
        }
      });

      // Subscribe to notifications
      await _subscribeToNotifications();
      _setState(BleConnectionState.connected);

      AppLogger.log(
        'Ready — notify: ${_notifyChar!.uuid}, '
            'write: ${_writeChar?.uuid ?? "none"}',
        'Connection ready',
      );
    } catch (e) {
      AppLogger.error('Connection failed', e.toString());
      _setState(BleConnectionState.error);
      rethrow;
    }
  }

  /// Writes data to the device's write characteristic.
  ///
  /// Throws if no write characteristic is available.
  Future<void> write(List<int> data) async {
    if (_writeChar == null) {
      throw StateError('No write characteristic available');
    }

    final withResponse = _writeChar!.properties.write;
    await _writeChar!.write(data, withoutResponse: !withResponse);
    AppLogger.log(
      'Wrote ${data.length} bytes: '
          '${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      'Data written to device',
    );
  }

  /// Disconnects from the device and cleans up all subscriptions.
  Future<void> disconnect() async {
    _intentionalDisconnect = true;

    await _connectionStateSub?.cancel();
    _connectionStateSub = null;

    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();

    try {
      await _device?.disconnect();
    } catch (e) {
      AppLogger.log(
        'Disconnect error (non-critical): $e',
        'Error during disconnection',
      );
    }

    _device = null;
    _notifyChar = null;
    _writeChar = null;
    _setState(BleConnectionState.disconnected);
  }

  /// Releases stream controllers. Call when the service is no longer needed.
  void dispose() {
    _connectionStateSub?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _stateController.close();
    _dataController.close();
  }

  // ── Private ──

  void _setState(BleConnectionState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void _logServices(List<BluetoothService> services) {
    for (final service in services) {
      AppLogger.log('Service: ${service.uuid}', 'Discovered BLE service');
      for (final char in service.characteristics) {
        final props = <String>[];
        if (char.properties.read) props.add('READ');
        if (char.properties.write) props.add('WRITE');
        if (char.properties.writeWithoutResponse) props.add('WRITE_NO_RESP');
        if (char.properties.notify) props.add('NOTIFY');
        if (char.properties.indicate) props.add('INDICATE');
        AppLogger.log(
          '  Char: ${char.uuid} [${props.join(', ')}]',
          'Discovered BLE characteristic',
        );
      }
    }
  }

  void _findCharacteristics(List<BluetoothService> services) {
    // Prefer FFE1 under FFE0 (Guoou paint gauge service)
    for (final service in services) {
      final isFFE0 = service.uuid.toString().toLowerCase().contains('ffe0');
      for (final char in service.characteristics) {
        final isFFE1 = char.uuid.toString().toLowerCase().contains('ffe1');

        if (isFFE0 && isFFE1) {
          if (char.properties.notify || char.properties.indicate) {
            _notifyChar = char;
            AppLogger.log(
              'Found gauge notify char: ${char.uuid}',
              'Discovered NOTIFY characteristic',
            );
          }
          if (char.properties.write || char.properties.writeWithoutResponse) {
            _writeChar = char;
            AppLogger.log(
              'Found gauge write char: ${char.uuid}',
              'Discovered WRITE characteristic',
            );
          }
        }
      }
    }

    // Fallback: find any NOTIFY and WRITE characteristics
    if (_notifyChar == null || _writeChar == null) {
      for (final service in services) {
        for (final char in service.characteristics) {
          if (_notifyChar == null &&
              (char.properties.notify || char.properties.indicate)) {
            _notifyChar = char;
            AppLogger.log(
              'Fallback notify char: ${char.uuid}',
              'Discovered fallback NOTIFY characteristic',
            );
          }
          if (_writeChar == null &&
              (char.properties.write || char.properties.writeWithoutResponse)) {
            _writeChar = char;
            AppLogger.log(
              'Fallback write char: ${char.uuid}',
              'Discovered fallback WRITE characteristic',
            );
          }
        }
      }
    }
  }

  Future<void> _subscribeToNotifications() async {
    if (_notifyChar == null) return;

    await _notifyChar!.setNotifyValue(true);
    AppLogger.log(
      'Subscribed to ${_notifyChar!.uuid}',
      'Notification subscription successful',
    );

    final sub = _notifyChar!.lastValueStream.listen((bytes) {
      if (bytes.isEmpty) return;
      if (!_dataController.isClosed) {
        _dataController.add(bytes);
      }
    });
    _subscriptions.add(sub);
  }
}
