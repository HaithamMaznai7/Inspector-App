// Same file bottom ya separate parser file
import 'package:paint_gauge/paint_gauge_platform_interface.dart';

enum FrameType { deviceInfo, deviceSettings, realtime, error }

class Frame {
  final FrameType type;
  final List<int> payload;
  Frame(this.type, this.payload);
}

class Parser {
  static Frame identify(List<int> bytes) {
    if (bytes.isEmpty) throw 'empty_frame';

    final op = bytes.first; // common pattern
    final payload = bytes.sublist(1);

    switch (op) {
      case 0x10: return Frame(FrameType.deviceInfo, payload);
      case 0x11: return Frame(FrameType.deviceSettings, payload);
      case 0x12: return Frame(FrameType.realtime, payload);
      case 0x7F: return Frame(FrameType.error, payload);
      default:   return Frame(FrameType.realtime, bytes); // fallback
    }
  }

  static DeviceInfo toDeviceInfo(Frame f) {
    // TODO: apni protocol spec se map karo
    // Example placeholders:
    final hw = 'v${f.payload[0]}.${f.payload[1]}';
    final sw = 'v${f.payload[2]}.${f.payload[3]}';
    final sn = String.fromCharCodes(f.payload.sublist(4, 14));
    final bat = f.payload.length > 14 ? f.payload[14] : 0;
    return DeviceInfo(
      hardwareVersion: hw,
      softwareVersion: sw,
      serialNumber: sn,
      battery: bat,
    );
  }

  static DeviceSettings toDeviceSettings(Frame f) {
    // TODO: map from bytes → fields
    return DeviceSettings(
      alarmOn:        (f.payload[0] & 0x01) != 0,
      mode:           f.payload[1],
      loLimit:        f.payload[2],
      hiLimit:        f.payload[3],
      seriousLoLimit: f.payload[4],
      seriousHiLimit: f.payload[5],
      groupNumber:    f.payload[6],
    );
  }

  static RealtimeData toRealtime(Frame f) {
    // TODO: map from bytes → values (e.g., little-endian ints)
    // Example: thickness (uint16), temperature (int16 / 10), timestamp ignored
    int u16(int i) => f.payload[i] | (f.payload[i+1] << 8);
    int s16(int i) {
      final v = u16(i);
      return v >= 0x8000 ? v - 0x10000 : v;
    }
    final th = u16(0).toDouble();     // microns?
    final temp = s16(2) / 10.0;       // 0.1°C
    final ts = DateTime.now().toIso8601String();
    return RealtimeData(thickness: th, temperature: temp, updateTime: ts);
  }

  static String toError(Frame f) {
    return '0x${f.payload.map((b)=>b.toRadixString(16).padLeft(2,'0')).join()}';
  }
}
