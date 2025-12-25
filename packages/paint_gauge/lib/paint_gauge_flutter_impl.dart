import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'models/parsing_helper.dart';
import 'paint_gauge_platform_interface.dart';

class FlutterPaintGaugeImpl extends PaintGuagePlatform {
  // ---- Streams ----
  final _scanCtrl = StreamController<List<PaintDevice>>.broadcast();
  final _connCtrl = StreamController<String>.broadcast();
  // If you don’t have device info/settings/realtime yet, just stub them:
  final _deviceInfoCtrl = StreamController<DeviceInfo>.broadcast();
  final _deviceSettingsCtrl = StreamController<DeviceSettings>.broadcast();
  final _realtimeCtrl = StreamController<RealtimeData>.broadcast();
  final _errorCtrl = StreamController<String>.broadcast();
  BluetoothDevice? _current;
  BluetoothCharacteristic? _notifyChar;

  FlutterPaintGaugeImpl() {
    // listen to connection changes if needed
  }

  // ---- Methods ----
  @override
  Future<String?> getPlatformVersion() async => Platform.operatingSystemVersion;

  @override
  Future<String?> getSdkVersion() async => 'flutter_blue_plus';

  @override
  Future<bool> isBluetoothEnabled() async {
    return await FlutterBluePlus.isSupported
        && await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
  }

  @override
  Future<void> enableBluetooth() async {
    // You can’t toggle BT from apps on modern Android; show UI on Flutter side.
  }

  @override
  Future<void> startScan() async {
    await FlutterBluePlus.stopScan();

    final seen = <String, PaintDevice>{};

    // Start scanning (low-latency for faster discovery)
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final d = r.device;
        final adv = r.advertisementData;
        final name = (d.platformName.isNotEmpty)
            ? d.platformName
            : (adv.advName.isNotEmpty
            ? adv.advName
            : (adv.localName.isNotEmpty ? adv.localName : d.remoteId.str));

        seen[d.remoteId.str] = PaintDevice(
          mac: d.remoteId.str,
          name: name,
          rssi: r.rssi,
        );
      }
      final list = seen.values.toList()
        ..sort((a, b) => b.rssi.compareTo(a.rssi));
      _scanCtrl.add(list);
    });
  }

  @override
  Future<void> stopScan() => FlutterBluePlus.stopScan();

  @override
  Future<bool> connectDevice(String mac) async {
    try {
      _current = BluetoothDevice.fromId(mac);

      _connCtrl.add('connecting');
      await _current!.connect(timeout: const Duration(seconds: 10), license: License.free);
      _connCtrl.add('connected');

      // (optional) MTU bump
      try { await _current!.requestMtu(247); } catch (_) {}

      final services = await _current!.discoverServices();

      // Prefer a known UUID list if tumhain pata ho; warna pehla NOTIFY choose:
      final List<BluetoothCharacteristic> notifyChars = [];
      for (final s in services) {
        for (final c in s.characteristics) {
          if (c.properties.notify || c.properties.indicate) {
            notifyChars.add(c);
          }
        }
      }
      if (notifyChars.isEmpty) {
        _errorCtrl.add('No NOTIFY characteristics found');
        return true; // connected but no data
      }

      // TODO: Agar tumhain exact UUID pata hai to yahan filter karo
      _notifyChar = notifyChars.first;

      await _notifyChar!.setNotifyValue(true);

      // Listen & demux → SDK-like streams
      _notifyChar!.onValueReceived.listen((bytes) {
        try {
          final frame = Parser.identify(bytes);

          switch (frame.type) {
            case FrameType.deviceInfo:
              _deviceInfoCtrl.add(Parser.toDeviceInfo(frame));
              break;
            case FrameType.deviceSettings:
              _deviceSettingsCtrl.add(Parser.toDeviceSettings(frame));
              break;
            case FrameType.realtime:
              _realtimeCtrl.add(Parser.toRealtime(frame));
              break;
            case FrameType.error:
              _errorCtrl.add(Parser.toError(frame));
              break;
          }
        } catch (e) {
          _errorCtrl.add('parse_failed: $e');
        }
      });

      // mirror connection state
      _current!.connectionState.listen((s) {
        _connCtrl.add(s.toString().split('.').last);
      });

      return true;
    } catch (e) {
      _connCtrl.add('disconnected');
      _errorCtrl.add('connect_failed: $e');
      return false;
    }
  }

  @override
  Future<void> disconnectDevice() async {
    try {
      await _notifyChar?.setNotifyValue(false);
    } catch (_) {}
    try {
      await _current?.disconnect();
    } catch (_) {}
    _connCtrl.add('disconnected');
  }

  @override
  Future<void> sync() async {} // no-op for now

  // ---- Streams exposed ----
  @override
  Stream<List<PaintDevice>> get scanResults => _scanCtrl.stream;

  @override
  Stream<String> get connectionStateStream => _connCtrl.stream;

  @override
  Stream<DeviceInfo> get deviceInfoStream => _deviceInfoCtrl.stream;

  @override
  Stream<DeviceSettings> get deviceSettingsStream => _deviceSettingsCtrl.stream;

  @override
  Stream<RealtimeData> get realtimeDataStream => _realtimeCtrl.stream;

  @override
  Stream<String> get errorStream => _errorCtrl.stream;
}
