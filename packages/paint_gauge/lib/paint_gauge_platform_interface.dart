import 'package:paint_gauge/paint_gauge_flutter_impl.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// import 'paint_gauge_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Data models for the paint gauge device
class PaintDevice {
  final String mac;
  final String name;
  final int rssi;

  PaintDevice({
    required this.mac,
    required this.name,
    required this.rssi,
  });

  factory PaintDevice.fromMap(Map<dynamic, dynamic> map) {
    return PaintDevice(
      mac: map['mac'] ?? '',
      name: map['name'] ?? '',
      rssi: map['rssi'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mac': mac,
      'name': name,
      'rssi': rssi,
    };
  }
}

class DeviceInfo {
  final String hardwareVersion;
  final String softwareVersion;
  final String serialNumber;
  final int battery;

  DeviceInfo({
    required this.hardwareVersion,
    required this.softwareVersion,
    required this.serialNumber,
    required this.battery,
  });

  factory DeviceInfo.fromMap(Map<dynamic, dynamic> map) {
    return DeviceInfo(
      hardwareVersion: map['hardwareVersion'] ?? '',
      softwareVersion: map['softwareVersion'] ?? '',
      serialNumber: map['serialNumber'] ?? '',
      battery: map['battery'] ?? 0,
    );
  }
}

class DeviceSettings {
  final bool alarmOn;
  final int mode;
  final int loLimit;
  final int hiLimit;
  final int seriousLoLimit;
  final int seriousHiLimit;
  final int groupNumber;

  DeviceSettings({
    required this.alarmOn,
    required this.mode,
    required this.loLimit,
    required this.hiLimit,
    required this.seriousLoLimit,
    required this.seriousHiLimit,
    required this.groupNumber,
  });

  factory DeviceSettings.fromMap(Map<dynamic, dynamic> map) {
    return DeviceSettings(
      alarmOn: map['alarmOn'] ?? false,
      mode: map['mode'] ?? 0,
      loLimit: map['loLimit'] ?? 0,
      hiLimit: map['hiLimit'] ?? 0,
      seriousLoLimit: map['seriousLoLimit'] ?? 0,
      seriousHiLimit: map['seriousHiLimit'] ?? 0,
      groupNumber: map['groupNumber'] ?? 0,
    );
  }
}

class RealtimeData {
  final double thickness;
  final double temperature;
  final String updateTime;

  RealtimeData({
    required this.thickness,
    required this.temperature,
    required this.updateTime,
  });

  factory RealtimeData.fromMap(Map<dynamic, dynamic> map) {
    return RealtimeData(
      thickness: (map['thickness'] ?? 0).toDouble(),
      temperature: (map['temperature'] ?? 0).toDouble(),
      updateTime: map['updateTime'] ?? '',
    );
  }
}

abstract class PaintGuagePlatform extends PlatformInterface {
  PaintGuagePlatform() : super(token: _token);

  static final Object _token = Object();
  static PaintGuagePlatform _instance = FlutterPaintGaugeImpl();

  static PaintGuagePlatform get instance => _instance;

  static set instance(PaintGuagePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Methods
  Future<String?> getPlatformVersion();
  Future<String?> getSdkVersion();
  Future<bool> isBluetoothEnabled();
  Future<void> enableBluetooth();
  Future<void> startScan();
  Future<void> stopScan();
  Future<bool> connectDevice(String mac);
  Future<void> disconnectDevice();
  Future<void> sync();

  // Streams
  Stream<List<PaintDevice>> get scanResults;
  Stream<DeviceInfo> get deviceInfoStream;
  Stream<DeviceSettings> get deviceSettingsStream;
  Stream<RealtimeData> get realtimeDataStream;
  Stream<String> get connectionStateStream;
  Stream<String> get errorStream;
}