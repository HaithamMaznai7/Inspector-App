import 'paint_gauge_flutter_impl.dart';
import 'paint_gauge_platform_interface.dart';

class PaintGauge {
  // Platform methods
  // void useFlutterImpl() {
  //   PaintGuagePlatform.instance = FlutterPaintGaugeImpl();
  // }

  Future<String?> getPlatformVersion() {
    return PaintGuagePlatform.instance.getPlatformVersion();
  }

  Future<String?> getSdkVersion() {
    return PaintGuagePlatform.instance.getSdkVersion();
  }

  Future<bool> isBluetoothEnabled() {
    return PaintGuagePlatform.instance.isBluetoothEnabled();
  }

  Future<void> enableBluetooth() {
    return PaintGuagePlatform.instance.enableBluetooth();
  }

  Future<void> startScan() {
    return PaintGuagePlatform.instance.startScan();
  }

  Future<void> stopScan() {
    return PaintGuagePlatform.instance.stopScan();
  }

  Future<bool> connectDevice(String mac) {
    return PaintGuagePlatform.instance.connectDevice(mac);
  }

  Future<void> disconnectDevice() {
    return PaintGuagePlatform.instance.disconnectDevice();
  }

  Future<void> sync() {
    return PaintGuagePlatform.instance.sync();
  }

  // Streams
  Stream<List<PaintDevice>> get scanResults =>
      PaintGuagePlatform.instance.scanResults;

  Stream<String> get connectionState =>
      PaintGuagePlatform.instance.connectionStateStream;

  Stream<DeviceInfo> get deviceInfo =>
      PaintGuagePlatform.instance.deviceInfoStream;

  Stream<DeviceSettings> get deviceSettings =>
      PaintGuagePlatform.instance.deviceSettingsStream;

  Stream<RealtimeData> get realtimeData =>
      PaintGuagePlatform.instance.realtimeDataStream;

  Stream<String> get errors =>
      PaintGuagePlatform.instance.errorStream;
}