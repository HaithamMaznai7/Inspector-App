import 'package:flutter/services.dart';

/// Thin Dart bridge to the native iOS `ObdBleWritePlugin` that performs BLE
/// Write Without Response on a characteristic whose `writeNR` property bit is
/// `false`.
///
/// On Android this class is unused — Android uses Bluetooth Classic SPP via
/// [SppPlugin].  The methods are safe to call on any platform; they simply
/// forward to the `obd_ble_write` method channel which only exists on iOS.
class ObdBleWrite {
  ObdBleWrite._();

  static const MethodChannel _channel = MethodChannel('obd_ble_write');

  /// Prepares the native bridge by retrieving the already-connected peripheral
  /// (via its own `CBCentralManager`), discovering the target service +
  /// characteristic, and caching the `CBCharacteristic` reference for
  /// subsequent [writeWithoutResponse] calls.
  ///
  /// Must be called **after** flutter_blue_plus has connected and discovered
  /// services on the same device.
  static Future<void> prepare({
    required String remoteId,
    required String serviceUuid,
    required String characteristicUuid,
  }) async {
    await _channel.invokeMethod<void>('prepare', {
      'remote_id': remoteId,
      'service_uuid': serviceUuid,
      'characteristic_uuid': characteristicUuid,
    });
  }

  /// Sends [data] to the cached characteristic using ATT Write Command
  /// (opcode 0x52 — write-without-response), bypassing flutter_blue_plus's
  /// native property validation.
  static Future<void> writeWithoutResponse(Uint8List data) async {
    await _channel.invokeMethod<void>('writeWithoutResponse', {'data': data});
  }

  /// Tears down the native bridge (disconnects the secondary
  /// `CBCentralManager` link and releases the cached characteristic).
  static Future<void> dispose() async {
    await _channel.invokeMethod<void>('dispose');
  }
}
