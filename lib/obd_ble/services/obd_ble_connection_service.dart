import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fahis_inspector/obd_ble/transport/ble_transport.dart';
import 'package:fahis_inspector/obd_ble/transport/obd_transport.dart';
import 'package:fahis_inspector/obd_ble/transport/spp.dart';
import 'package:fahis_inspector/obd_ble/util/obd_logger.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';

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

/// Encapsulates the OBD-II adapter lifecycle (Veepeak / generic ELM327).
///
/// Transport is chosen per-platform:
///  - **Android** uses Bluetooth Classic SPP (`Spp` static facade → native
///    `SppPlugin.kt`). Most consumer ELM327 adapters (Veepeak Mini, no-name
///    clones) only wire the ELM327 UART to the Classic Bluetooth side; their
///    BLE GATT server is a stub on those units.
///  - **iOS** uses BLE GATT (`BleTransport` → `flutter_blue_plus`). Apple
///    forbids RFCOMM for non-MFi devices, so iOS users need a true BLE
///    adapter such as the Veepeak OBDCheck BLE.
///
/// The class deliberately keeps its old name and public API so the rest of
/// the app (controller, ELM327 service, UI) is untouched by the per-platform
/// transport choice.
class ObdBleConnectionService {
  ObdBleConnectionService() : _transport = _createTransport();

  static ObdTransport _createTransport() {
    if (Platform.isIOS) return BleTransport();
    return _SppTransport();
  }

  final ObdTransport _transport;

  StreamSubscription<Uint8List>? _inputSub;

  // True while the user has explicitly called disconnect() — prevents the
  // socket's onDone callback from being treated as a lost link.
  bool _intentionalDisconnect = false;

  // Tracks whether we currently hold an open SPP socket. Replaces the old
  // `BluetoothConnection.isConnected` getter — there's no connection object
  // to query when we're talking to the native plugin directly.
  bool _isConnected = false;

  final _stateController = StreamController<ObdBleConnectionState>.broadcast();
  final _dataController = StreamController<List<int>>.broadcast();

  Stream<ObdBleConnectionState> get connectionState => _stateController.stream;
  Stream<List<int>> get notifications => _dataController.stream;

  bool get canWrite => _isConnected;

  ObdBleConnectionState _currentState = ObdBleConnectionState.disconnected;
  ObdBleConnectionState get currentState => _currentState;

  /// Opens the underlying transport link to [deviceMac] (MAC on Android, BLE
  /// remote-id on iOS). Throws on failure (caller's `try/catch` already
  /// handles the snackbar + disconnect).
  Future<void> connect(String deviceMac) async {
    _setState(ObdBleConnectionState.connecting);

    try {
      AppLogger.log('[OBD BT]', 'Connecting to $deviceMac');
      ObdLogger.info(
        'Transport connect → $deviceMac (${_transport.runtimeType})',
      );

      await _transport.connect(deviceMac);
      AppLogger.log('[OBD BT]', 'Transport open');
      ObdLogger.info('Transport open');

      _intentionalDisconnect = false;
      _isConnected = true;

      _inputSub = _transport.byteStream.listen(
        _onIncomingBytes,
        onDone: _onSocketClosed,
        onError: (Object e) {
          AppLogger.error('[OBD BT]', 'Transport stream error', e);
          ObdLogger.error('Transport stream error: $e');
          if (!_intentionalDisconnect) {
            _isConnected = false;
            _setState(ObdBleConnectionState.lostConnection);
          }
        },
        cancelOnError: false,
      );

      _setState(ObdBleConnectionState.connected);
    } catch (e) {
      AppLogger.error('[OBD BT]', 'Connection failed', e);
      ObdLogger.error('Transport connect failed: $e');
      _isConnected = false;
      _setState(ObdBleConnectionState.error);
      rethrow;
    }
  }

  /// Writes [data] to the transport. Used by the ELM327 service for `ATZ\r`
  /// and every other command — serialization is enforced upstream by the
  /// `Elm327CommandService`'s single-flight lock.
  Future<void> write(List<int> data) async {
    if (!_isConnected) {
      ObdLogger.error('TX rejected — transport not connected');
      throw StateError('OBD transport not connected');
    }
    ObdLogger.send(
      'TX (${data.length}): hex=${_hex(data)} ascii="${_ascii(data)}"',
    );
    await _transport.write(data);
  }

  Future<void> disconnect() async {
    ObdLogger.info('Connection service disconnect requested');
    _intentionalDisconnect = true;
    _isConnected = false;

    await _inputSub?.cancel();
    _inputSub = null;

    try {
      await _transport.disconnect();
    } catch (e) {
      AppLogger.log('[OBD BT]', 'Disconnect error (non-critical): $e');
      ObdLogger.warn('Disconnect error (non-critical): $e');
    }

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
    ObdLogger.recv(
      'RX (${bytes.length}): hex=${_hex(bytes)} ascii="${_ascii(bytes)}"',
    );

    if (!_dataController.isClosed) {
      _dataController.add(bytes);
    }
  }

  void _onSocketClosed() {
    AppLogger.log(
      '[OBD BT]',
      'Transport closed (intentional='
          '$_intentionalDisconnect)',
    );
    ObdLogger.info(
      'Transport closed (intentional=$_intentionalDisconnect)',
    );
    _isConnected = false;
    if (_intentionalDisconnect) return;
    if (_currentState == ObdBleConnectionState.connected) {
      _setState(ObdBleConnectionState.lostConnection);
    }
  }

  void _setState(ObdBleConnectionState state) {
    _currentState = state;
    ObdLogger.info('State → ${state.name}');
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

/// Adapter that exposes the static [Spp] facade through the [ObdTransport]
/// contract. Kept private to this file because the rest of the app talks to
/// `ObdTransport` only.
class _SppTransport implements ObdTransport {
  @override
  Future<void> connect(String deviceId) => Spp.connect(deviceId);

  @override
  Future<void> disconnect() => Spp.disconnect();

  @override
  Future<void> write(List<int> data) => Spp.write(data);

  @override
  Stream<Uint8List> get byteStream => Spp.byteStream();
}
