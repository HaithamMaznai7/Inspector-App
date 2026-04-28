import 'dart:async';

import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Connection state exposed to consumers. Same shape as the paint gauge's
/// state enum so the controller pattern is identical.
enum ObdBleConnectionState {
  disconnected,
  connecting,
  connected,
  error,

  /// Device dropped the link unexpectedly (e.g. LINK_SUPERVISION_TIMEOUT).
  /// Distinct from [disconnected] which is user-initiated via [disconnect()].
  lostConnection,
}

/// Encapsulates the BLE lifecycle for a Veepeak / ELM327 OBD adapter.
///
/// Connects to a Veepeak / ELM327 OBD adapter and exposes the first NOTIFY
/// + WRITE characteristic pair the device advertises.
class ObdBleConnectionService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _notifyChar;
  BluetoothCharacteristic? _writeChar;
  final List<StreamSubscription<List<int>>> _subscriptions = [];

  // True while the user has explicitly called disconnect() — prevents the
  // device.connectionState listener from treating it as a lost link.
  bool _intentionalDisconnect = false;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSub;

  final _stateController = StreamController<ObdBleConnectionState>.broadcast();
  final _dataController = StreamController<List<int>>.broadcast();

  Stream<ObdBleConnectionState> get connectionState => _stateController.stream;
  Stream<List<int>> get notifications => _dataController.stream;

  bool get canWrite => _writeChar != null;

  ObdBleConnectionState _currentState = ObdBleConnectionState.disconnected;
  ObdBleConnectionState get currentState => _currentState;

  Future<void> connect(String deviceId) async {
    _setState(ObdBleConnectionState.connecting);

    try {
      _device = BluetoothDevice.fromId(deviceId);
      AppLogger.log('[OBD BLE]', 'Connecting to $deviceId');

      await _device!
          .connect(timeout: const Duration(seconds: 15), license: License.free)
          .catchError((e) {
            AppLogger.error('[OBD BLE]', 'Connection error', e);
            throw e;
          });

      AppLogger.log('[OBD BLE]', 'Connected to ${_device!.platformName}');

      try {
        await _device!.requestMtu(247);
      } catch (e) {
        AppLogger.log('[OBD BLE]', 'MTU request failed (not critical): $e');
      }

      final services = await _device!.discoverServices();
      _findCharacteristics(services);

      if (_notifyChar == null || _writeChar == null) {
        AppLogger.error(
          '[OBD BLE]',
          'No NOTIFY+WRITE characteristic pair found',
          'characteristics not discovered',
        );
        _setState(ObdBleConnectionState.error);
        return;
      }

      _connectionStateSub = _device!.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected &&
            !_intentionalDisconnect &&
            _currentState == ObdBleConnectionState.connected) {
          AppLogger.log('[OBD BLE]', 'Device dropped connection unexpectedly');
          _notifyChar = null;
          _writeChar = null;
          _setState(ObdBleConnectionState.lostConnection);
        }
      });

      await _subscribeToNotifications();
      _setState(ObdBleConnectionState.connected);
    } catch (e) {
      AppLogger.error('[OBD BLE]', 'Connection failed', e);
      _setState(ObdBleConnectionState.error);
      rethrow;
    }
  }

  Future<void> write(List<int> data) async {
    if (_writeChar == null) {
      throw StateError('No write characteristic available');
    }
    final withResponse = _writeChar!.properties.write;
    await _writeChar!.write(data, withoutResponse: !withResponse);
  }

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
      AppLogger.log('[OBD BLE]', 'Disconnect error (non-critical): $e');
    }

    _device = null;
    _notifyChar = null;
    _writeChar = null;
    _setState(ObdBleConnectionState.disconnected);
  }

  void dispose() {
    _connectionStateSub?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _stateController.close();
    _dataController.close();
  }

  // ── Private ─────────────────────────────────────────────────────────────

  void _setState(ObdBleConnectionState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void _findCharacteristics(List<BluetoothService> services) {
    for (final service in services) {
      for (final char in service.characteristics) {
        if (_notifyChar == null &&
            (char.properties.notify || char.properties.indicate)) {
          _notifyChar = char;
          AppLogger.log('[OBD BLE]', 'Notify char: ${char.uuid}');
        }
        if (_writeChar == null &&
            (char.properties.write || char.properties.writeWithoutResponse)) {
          _writeChar = char;
          AppLogger.log('[OBD BLE]', 'Write char: ${char.uuid}');
        }
      }
      if (_notifyChar != null && _writeChar != null) break;
    }
  }

  Future<void> _subscribeToNotifications() async {
    if (_notifyChar == null) return;

    await _notifyChar!.setNotifyValue(true);

    final sub = _notifyChar!.lastValueStream.listen((bytes) {
      if (bytes.isEmpty) return;
      if (!_dataController.isClosed) {
        _dataController.add(bytes);
      }
    });
    _subscriptions.add(sub);
  }
}
