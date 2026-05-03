import 'dart:async';
import 'dart:typed_data';

/// Transport contract for the ELM327 / OBD-II adapter byte pipe.
///
/// Two implementations exist:
///  - Bluetooth Classic SPP / RFCOMM via the native `SppPlugin` (Android,
///    used by the Veepeak Mini and most cheap clone adapters that only
///    expose a serial profile).
///  - Bluetooth LE GATT via `flutter_blue_plus` (iOS, BLE-capable adapters
///    such as Veepeak OBDCheck BLE — Apple forbids RFCOMM for non-MFi
///    devices, so iOS users need a true BLE adapter).
///
/// `ObdBleConnectionService` consumes this interface so the rest of the OBD
/// stack (`Elm327CommandService`, parser, controller, repository) is fully
/// transport-agnostic and identical across platforms.
abstract class ObdTransport {
  /// Opens the underlying socket / GATT link to [deviceId] (MAC on Android,
  /// CoreBluetooth UUID on iOS). Throws on failure.
  Future<void> connect(String deviceId);

  /// Closes the link. Safe to call when nothing is open.
  Future<void> disconnect();

  /// Sends one chunk of bytes (an ASCII ELM327 command terminated by `\r`).
  Future<void> write(List<int> data);

  /// Stream of incoming byte chunks. Emits an error if the link drops
  /// unexpectedly so the connection service can transition to
  /// `lostConnection` the same way it does for SPP socket close.
  Stream<Uint8List> get byteStream;
}
