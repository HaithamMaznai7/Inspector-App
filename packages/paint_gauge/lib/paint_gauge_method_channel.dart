// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
//
// import 'paint_gauge_platform_interface.dart';
//
// /// Android implementation using MethodChannel + EventChannels.
// class MethodChannelPaintGuage extends PaintGuagePlatform {
//   @visibleForTesting
//   final methodChannel = const MethodChannel('paint_gauge');
//
//   // EventChannels
//   static const _scanChannel = EventChannel('paint_gauge/scan');
//   static const _connectionChannel = EventChannel('paint_gauge/connection');
//   static const _deviceInfoChannel = EventChannel('paint_gauge/device_info');
//   static const _deviceSettingsChannel = EventChannel('paint_gauge/device_settings');
//   static const _realtimeChannel = EventChannel('paint_gauge/realtime');
//   static const _errorChannel = EventChannel('paint_gauge/errors');
//
//   // Stream controllers (broadcast) to be robust if we want to transform / cache
//   late final Stream<List<PaintDevice>> _scanResultsStream =
//   _scanChannel.receiveBroadcastStream().map<List<PaintDevice>>((dynamic data) {
//     // Expecting a List<Map>
//     final list = (data as List).cast<dynamic>();
//     return list.map((e) => PaintDevice.fromMap(Map<String, dynamic>.from(e as Map))).toList();
//   });
//
//   late final Stream<String> _connectionStateStream =
//   _connectionChannel.receiveBroadcastStream().map<String>((dynamic data) {
//     return data as String;
//   });
//
//   late final Stream<DeviceInfo> _deviceInfoStream =
//   _deviceInfoChannel.receiveBroadcastStream().map<DeviceInfo>((dynamic data) {
//     return DeviceInfo.fromMap(Map<String, dynamic>.from(data as Map));
//   });
//
//   late final Stream<DeviceSettings> _deviceSettingsStream =
//   _deviceSettingsChannel.receiveBroadcastStream().map<DeviceSettings>((dynamic data) {
//     return DeviceSettings.fromMap(Map<String, dynamic>.from(data as Map));
//   });
//
//   late final Stream<RealtimeData> _realtimeDataStream =
//   _realtimeChannel.receiveBroadcastStream().map<RealtimeData>((dynamic data) {
//     return RealtimeData.fromMap(Map<String, dynamic>.from(data as Map));
//   });
//
//   late final Stream<String> _errorStream =
//   _errorChannel.receiveBroadcastStream().map<String>((dynamic data) => data as String);
//
//   @override
//   Future<String?> getPlatformVersion() =>
//       methodChannel.invokeMethod<String>('getPlatformVersion');
//
//   @override
//   Future<void> enableBluetooth() => methodChannel.invokeMethod<void>('enableBluetooth');
//
//   @override
//   Future<void> startScan() => methodChannel.invokeMethod<void>('startScan');
//
//   @override
//   Future<void> stopScan() => methodChannel.invokeMethod<void>('stopScan');
//
//   @override
//   Future<bool> connectDevice(String mac) async {
//     final ok = await methodChannel.invokeMethod<bool>('connectDevice', {'mac': mac});
//     return ok ?? false;
//   }
//
//   @override
//   Future<void> disconnectDevice() => methodChannel.invokeMethod<void>('disconnectDevice');
//
//   @override
//   Future<void> sync() => methodChannel.invokeMethod<void>('sync');
//
//   // Streams exposed to platform interface
//   @override
//   Stream<List<PaintDevice>> get scanResults => _scanResultsStream;
//
//   @override
//   Stream<String> get connectionStateStream => _connectionStateStream;
//
//   @override
//   Stream<DeviceInfo> get deviceInfoStream => _deviceInfoStream;
//
//   @override
//   Stream<DeviceSettings> get deviceSettingsStream => _deviceSettingsStream;
//
//   @override
//   Stream<RealtimeData> get realtimeDataStream => _realtimeDataStream;
//
//   @override
//   Stream<String> get errorStream => _errorStream;
//
//   @override
//   Future<String?> getSdkVersion() {
//     return methodChannel.invokeMethod<String>('getSdkVersion');
//   }
//
//   @override
//   Future<bool> isBluetoothEnabled() async {
//     final v = await methodChannel.invokeMethod<bool>('isBluetoothEnabled');
//     return v ?? false;
//   }
// }
