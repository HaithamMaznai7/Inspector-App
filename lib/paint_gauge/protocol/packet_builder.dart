import 'crc16.dart';
import 'models.dart';

/// Builds command packets per the Guoou BLE protocol.
///
/// Packet format: [bytesCnt] [scriptCmd] [textBody...] [checkHi] [checkLo]
/// - bytesCnt = length of textBody (0–32)
/// - When cmd high bit = 1: checksum = CRC16 over [bytesCnt, cmd, body]
/// - When cmd high bit = 0: checksum = fixed 0x55 0xAA
///
/// We always use CRC16 (high bit = 1) for reliability. The device accepts both.
class PacketBuilder {
  const PacketBuilder._();

  /// Assembles a complete packet with CRC16 checksum.
  static List<int> buildPacket(int scriptCmd, [List<int> body = const []]) {
    assert(body.length <= 32, 'Text body max 32 bytes');
    final bytesCnt = body.length;
    final payload = [bytesCnt, scriptCmd, ...body];

    // Always use CRC16 (set high bit of cmd)
    final useCrc = (scriptCmd & 0x80) != 0;
    if (useCrc) {
      final crc = crc16Bytes(payload);
      return [...payload, ...crc];
    } else {
      // Fixed checksum for cmd with high bit = 0
      return [...payload, 0x55, 0xAA];
    }
  }

  /// Splits a packet into BLE frames of at most [maxFrameSize] bytes.
  /// The sender must insert a 125ms delay between frames.
  static List<List<int>> splitFrames(
    List<int> packet, {
    int maxFrameSize = 20,
  }) {
    if (packet.length <= maxFrameSize) return [packet];

    final frames = <List<int>>[];
    for (var i = 0; i < packet.length; i += maxFrameSize) {
      final end =
          (i + maxFrameSize > packet.length) ? packet.length : i + maxFrameSize;
      frames.add(packet.sublist(i, end));
    }
    return frames;
  }

  // ── CarHandy mode queries (Section 4.1–4.8) ──

  /// 4.1: Query alarm switch status. Cmd=0xBF, body=0x41.
  static List<int> queryAlarmSwitch() => buildPacket(0xBF, [0x41]);

  /// 4.2: Query upper limit alarm value. Cmd=0xBF, body=0x5E.
  static List<int> queryUpperAlarm() => buildPacket(0xBF, [0x5E]);

  /// 4.3: Query lower limit alarm value. Cmd=0xBF, body=0x56.
  static List<int> queryLowerAlarm() => buildPacket(0xBF, [0x56]);

  /// 4.4: Query serious upper limit alarm value. Cmd=0xBF, body=0x68.
  static List<int> querySeriousUpperAlarm() => buildPacket(0xBF, [0x68]);

  /// 4.5: Query serious lower limit alarm value. Cmd=0xBF, body=0x6C.
  static List<int> querySeriousLowerAlarm() => buildPacket(0xBF, [0x6C]);

  /// 4.7: Get data from specified range. Cmd=0xBF, body=[0x40, firstIndex, count].
  /// Max 10 items per request.
  static List<int> getDataRange(int firstIndex, int count) {
    assert(count >= 1 && count <= 20, 'Count must be 1–20');
    return buildPacket(0xBF, [0x40, firstIndex & 0xFF, count & 0xFF]);
  }

  /// 4.8: Query data count in data set. Cmd=0xBF, body=0x43.
  static List<int> queryDataCount() => buildPacket(0xBF, [0x43]);

  // ── CarHandy mode setters (Section 4.9–4.14) ──

  /// 4.9: Set alarm switch ON/OFF. Cmd=0xBD, body=[0x41, value].
  static List<int> setAlarmSwitch(bool enabled) =>
      buildPacket(0xBD, [0x41, enabled ? 0x01 : 0x00]);

  /// 4.10: Set upper limit alarm value. Cmd=0xBD, body=[0x5E, int16LE].
  static List<int> setUpperAlarm(int value) =>
      buildPacket(0xBD, [0x5E, value & 0xFF, (value >> 8) & 0xFF]);

  /// 4.11: Set lower limit alarm value. Cmd=0xBD, body=[0x56, int16LE].
  static List<int> setLowerAlarm(int value) =>
      buildPacket(0xBD, [0x56, value & 0xFF, (value >> 8) & 0xFF]);

  /// 4.12: Set serious upper limit alarm value. Cmd=0xBD, body=[0x68, int16LE].
  static List<int> setSeriousUpperAlarm(int value) =>
      buildPacket(0xBD, [0x68, value & 0xFF, (value >> 8) & 0xFF]);

  /// 4.13: Set serious lower limit alarm value. Cmd=0xBD, body=[0x6C, int16LE].
  static List<int> setSeriousLowerAlarm(int value) =>
      buildPacket(0xBD, [0x6C, value & 0xFF, (value >> 8) & 0xFF]);

  /// 4.14: Delete specified number of data from group. Cmd=0xBD, body=[0x2D, count].
  static List<int> deleteData(int count) =>
      buildPacket(0xBD, [0x2D, count & 0xFF]);

  // ── Mode commands (Section 4.17–4.18) ──

  /// 4.17: Query current measurement mode. Cmd=0xBF, body=0x6D.
  static List<int> queryMode() => buildPacket(0xBF, [0x6D]);

  /// 4.18: Set measurement mode. Cmd=0xBD, body=[0x6D, mode].
  static List<int> setMode(MeasurementMode mode) =>
      buildPacket(0xBD, [0x6D, mode.value]);

  // ── CarPro mode commands (Section 4.19–4.24) ──

  /// 4.19: Clear data of a vehicle panel. Cmd=0xBD, body=[0x64, uint16LE].
  static List<int> clearPanelData(CarPart panel) =>
      buildPacket(0xBD, [0x64, panel.value & 0xFF, (panel.value >> 8) & 0xFF]);

  /// 4.20: Get vehicle panel data. Cmd=0xBF, body=[0x67, uint16LE].
  static List<int> getPanelData(CarPart panel) =>
      buildPacket(0xBF, [0x67, panel.value & 0xFF, (panel.value >> 8) & 0xFF]);

  /// 4.21: Query current panel number. Cmd=0xBF, body=0x70.
  static List<int> queryCurrentPanel() => buildPacket(0xBF, [0x70]);

  /// 4.22: Toggle current panel. Cmd=0xBD, body=[0x70, uint16LE].
  static List<int> togglePanel(CarPart panel) =>
      buildPacket(0xBD, [0x70, panel.value & 0xFF, (panel.value >> 8) & 0xFF]);

  /// 4.23: Toggle car data groups. Cmd=0xBD, body=[0x63, uint16LE, clearFlag].
  /// [clear]=true sends 0xAA to clear after toggle.
  static List<int> toggleCarDataGroup(int groupNumber, {bool clear = false}) =>
      buildPacket(0xBD, [
        0x63,
        groupNumber & 0xFF,
        (groupNumber >> 8) & 0xFF,
        clear ? 0xAA : 0x00,
      ]);

  /// 4.24: Delete all panels data for a vehicle. Cmd=0xBD, body=[0x73, uint16LE].
  /// [vehicleNumber] must be 1–999.
  static List<int> deleteAllPanelsData(int vehicleNumber) {
    assert(
      vehicleNumber >= 1 && vehicleNumber <= 999,
      'Vehicle number must be 1–999',
    );
    return buildPacket(
      0xBD,
      [0x73, vehicleNumber & 0xFF, (vehicleNumber >> 8) & 0xFF],
    );
  }
}
