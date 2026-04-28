import 'dart:async';
import 'dart:typed_data';

import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// Connection state exposed to consumers. Same shape as the paint gauge's
/// state enum so the controller pattern is identical.
enum ObdBleConnectionState {
  disconnected,
  connecting,
  connected,
  error,

  /// Device dropped the link unexpectedly (e.g. socket closed by peer).
  /// Distinct from [disconnected] which is user-initiated via [disconnect()].
  lostConnection,
}

/// Encapsulates the Bluetooth Classic (SPP / RFCOMM) lifecycle for a Veepeak
/// or other ELM327 OBD-II adapter on Android.
///
/// Why Classic and not BLE: most consumer ELM327 adapters (Veepeak Mini, older
/// OBDCheck BLE, no-name clones) only wire the ELM327 UART to the Classic
/// Bluetooth side, even when they advertise a BLE GATT profile. On the BLE
/// side every GATT write returns `GATT_SUCCESS` but the bytes never reach the
/// ELM327 chip and no notifications fire — the BLE GATT server is essentially
/// a stub. CarScanner, Torque, and the working reference apps all use Classic
/// SPP for this reason. iOS callers get no transport here; the controller is
/// expected to gate the "connect" path with `Platform.isAndroid` and route
/// iOS users to manual entry.
///
/// The class deliberately keeps its old name and public API so the rest of
/// the app (controller, ELM327 service, UI) is untouched by the transport
/// swap. Internally it owns a single SPP socket via [BluetoothConnection].
class ObdBleConnectionService {
  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _inputSub;

  // True while the user has explicitly called disconnect() — prevents the
  // socket's onDone callback from being treated as a lost link.
  bool _intentionalDisconnect = false;

  final _stateController = StreamController<ObdBleConnectionState>.broadcast();
  final _dataController = StreamController<List<int>>.broadcast();

  Stream<ObdBleConnectionState> get connectionState => _stateController.stream;
  Stream<List<int>> get notifications => _dataController.stream;

  bool get canWrite => _connection?.isConnected ?? false;

  ObdBleConnectionState _currentState = ObdBleConnectionState.disconnected;
  ObdBleConnectionState get currentState => _currentState;

  /// Opens an RFCOMM SPP connection to [deviceMac] using the well-known
  /// Serial Port Profile UUID (`00001101-…`). The remote device must already
  /// be bonded — pairing happens through the Android Bluetooth settings, not
  /// in-app. Throws on failure (caller's `try/catch` already handles the
  /// snackbar + disconnect).
  Future<void> connect(String deviceMac) async {
    _setState(ObdBleConnectionState.connecting);

    try {
      AppLogger.log('[OBD BT]', 'Connecting to $deviceMac');

      _connection = await BluetoothConnection.toAddress(deviceMac);
      AppLogger.log('[OBD BT]', 'SPP socket open');

      _intentionalDisconnect = false;
      _inputSub = _connection!.input!.listen(
        _onIncomingBytes,
        onDone: _onSocketClosed,
        onError: (Object e) {
          AppLogger.error('[OBD BT]', 'Socket stream error', e);
          if (!_intentionalDisconnect) {
            _setState(ObdBleConnectionState.lostConnection);
          }
        },
        cancelOnError: false,
      );

      _setState(ObdBleConnectionState.connected);
    } catch (e) {
      AppLogger.error('[OBD BT]', 'Connection failed', e);
      _setState(ObdBleConnectionState.error);
      rethrow;
    }
  }

  /// Writes [data] to the SPP socket and waits until the OS confirms the
  /// bytes have been flushed. Used by the ELM327 service for `ATZ\r` and
  /// every other command — serialization is enforced upstream.
  Future<void> write(List<int> data) async {
    final connection = _connection;
    if (connection == null || !connection.isConnected) {
      throw StateError('SPP socket not connected');
    }
    connection.output.add(Uint8List.fromList(data));
    await connection.output.allSent;
  }

  Future<void> disconnect() async {
    _intentionalDisconnect = true;

    await _inputSub?.cancel();
    _inputSub = null;

    try {
      await _connection?.close();
    } catch (e) {
      AppLogger.log('[OBD BT]', 'Disconnect error (non-critical): $e');
    }

    _connection = null;
    _setState(ObdBleConnectionState.disconnected);
  }

  void dispose() {
    _inputSub?.cancel();
    _inputSub = null;
    _stateController.close();
    _dataController.close();
  }

  // ── Private ─────────────────────────────────────────────────────────────

  void _onIncomingBytes(Uint8List bytes) {
    if (bytes.isEmpty) return;

    // Raw byte trace mirrors the BLE-era log so capture parity stays
    // intact for support; ELM327 responses are ASCII so showing both forms
    // makes framing/CR-LF bugs immediately obvious.
    AppLogger.log(
      '[OBD BT]',
      'RX bytes (${bytes.length}): hex=${_hex(bytes)} '
      'ascii="${_ascii(bytes)}"',
    );

    if (!_dataController.isClosed) {
      _dataController.add(bytes);
    }
  }

  void _onSocketClosed() {
    AppLogger.log('[OBD BT]', 'SPP socket closed (intentional='
        '$_intentionalDisconnect)');
    if (_intentionalDisconnect) return;
    if (_currentState == ObdBleConnectionState.connected) {
      _setState(ObdBleConnectionState.lostConnection);
    }
  }

  void _setState(ObdBleConnectionState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  static String _hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  /// Renders printable ASCII as-is and escapes control bytes so a single log
  /// line stays readable in `flutter logs` (matches the BLE service format).
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
