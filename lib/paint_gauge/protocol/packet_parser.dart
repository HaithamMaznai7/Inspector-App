import 'models.dart';

/// Parsed result from an incoming BLE packet.
sealed class ParsedPacket {
  const ParsedPacket();
}

/// ACK — device accepted the command (Section 3.1).
/// Bytes: 00 88 01 D6
class AckPacket extends ParsedPacket {
  const AckPacket();
}

/// NAK — device rejected the packet format (Section 3.2).
/// Bytes: 00 95 C1 DF
class NakPacket extends ParsedPacket {
  const NakPacket();
}

/// Cancel — command not supported by device (Section 3.3).
/// Bytes: 00 98 00 1A
class CancelPacket extends ParsedPacket {
  const CancelPacket();
}

/// Real-time measurement data upload (Section 5).
/// Packet: 08 BD 52 [partId uint16] [dataStart] [dataCnt] [value uint24] [CRC]
class MeasurementPacket extends ParsedPacket {
  final CarPart? carPart;
  final int partId;
  final int dataStart;
  final int dataCnt;
  final DeviceMeasurement measurement;

  const MeasurementPacket({
    required this.carPart,
    required this.partId,
    required this.dataStart,
    required this.dataCnt,
    required this.measurement,
  });
}

/// Part selection notification (0xBD 0x70) — device switched panel.
class PartSelectionPacket extends ParsedPacket {
  final CarPart? carPart;
  final int partId;

  const PartSelectionPacket({required this.carPart, required this.partId});
}

/// Response to alarm switch query (Section 4.1/4.9).
/// Packet: 02 BD 41 [uint8] [CRC]
class AlarmSwitchResponse extends ParsedPacket {
  final bool enabled;
  const AlarmSwitchResponse({required this.enabled});
}

/// Response to alarm value queries (Sections 4.2–4.5, 4.10–4.13).
/// Packet: 03 BD [subCmd] [int16LE] [CRC]
class AlarmValueResponse extends ParsedPacket {
  final int subCommand;
  final int value;
  const AlarmValueResponse({required this.subCommand, required this.value});
}

/// Response to mode query (Section 4.17/4.18).
/// Packet: 02 BD 6D [uint8] [CRC]
class ModeResponse extends ParsedPacket {
  final MeasurementMode? mode;
  final int rawMode;
  const ModeResponse({required this.mode, required this.rawMode});
}

/// Response to data count query (Section 4.8).
/// Packet: 02 BD 43 [uint8] [CRC]
class DataCountResponse extends ParsedPacket {
  final int count;
  const DataCountResponse({required this.count});
}

/// Response to data range query (Section 4.7).
/// Packet: [cnt] BD 40 [validCount] [uint24 array] [CRC]
class DataRangeResponse extends ParsedPacket {
  final int totalValidCount;
  final List<DeviceMeasurement> measurements;
  const DataRangeResponse({
    required this.totalValidCount,
    required this.measurements,
  });
}

/// Response to panel data query (Section 4.20).
/// Packet: [cnt] BD 67 [uint16 panelId] [Group uint24 array] [CRC]
class PanelDataResponse extends ParsedPacket {
  final CarPart? carPart;
  final int partId;
  final List<DeviceMeasurement> measurements;
  const PanelDataResponse({
    required this.carPart,
    required this.partId,
    required this.measurements,
  });
}

/// Response to current panel query (Section 4.21).
/// Packet: 03 BD 70 [uint16LE] [CRC]
class CurrentPanelResponse extends ParsedPacket {
  final CarPart? carPart;
  final int partId;
  const CurrentPanelResponse({required this.carPart, required this.partId});
}

/// Response to delete data command (Section 4.14).
/// Echoes back the actual number deleted.
class DeleteDataResponse extends ParsedPacket {
  final int deletedCount;
  const DeleteDataResponse({required this.deletedCount});
}

/// Response to clear panel data command (Section 4.19).
/// Device echoes: [bytesCnt] BD 64 [uint16LE panelId] [CRC]
class ClearPanelResponse extends ParsedPacket {
  final CarPart? carPart;
  final int partId;
  const ClearPanelResponse({required this.carPart, required this.partId});
}

/// Packet that could not be parsed into a known type.
class UnknownPacket extends ParsedPacket {
  final List<int> rawBytes;
  const UnknownPacket({required this.rawBytes});
}

/// Parses raw BLE bytes into a typed [ParsedPacket].
class PacketParser {
  const PacketParser._();

  static ParsedPacket parse(List<int> bytes) {
    if (bytes.isEmpty) return UnknownPacket(rawBytes: bytes);

    // Check for fixed response codes (Section 3)
    if (bytes.length >= 4) {
      if (_matchesBytes(bytes, [0x00, 0x88])) return const AckPacket();
      if (_matchesBytes(bytes, [0x00, 0x95])) return const NakPacket();
      if (_matchesBytes(bytes, [0x00, 0x98])) return const CancelPacket();
    }

    if (bytes.length < 4) return UnknownPacket(rawBytes: bytes);

    final scriptCmd = bytes[1];
    final subCmd = bytes[2];

    // Measurement data upload: BD 52 (Section 5)
    if (scriptCmd == 0xBD && subCmd == 0x52 && bytes.length >= 10) {
      return _parseMeasurement(bytes);
    }

    // Alarm switch response: BD 41 (Section 4.1/4.9)
    if (scriptCmd == 0xBD && subCmd == 0x41 && bytes[0] == 0x02) {
      return AlarmSwitchResponse(enabled: bytes[3] == 0x01);
    }

    // Mode response: BD 6D (Section 4.17/4.18)
    if (scriptCmd == 0xBD && subCmd == 0x6D && bytes[0] == 0x02) {
      return ModeResponse(
        mode: MeasurementMode.fromValue(bytes[3]),
        rawMode: bytes[3],
      );
    }

    // Data count response: BD 43 (Section 4.8)
    if (scriptCmd == 0xBD && subCmd == 0x43 && bytes[0] == 0x02) {
      return DataCountResponse(count: bytes[3]);
    }

    // Delete data response: BD 2D (Section 4.14)
    if (scriptCmd == 0xBD && subCmd == 0x2D && bytes[0] == 0x02) {
      return DeleteDataResponse(deletedCount: bytes[3]);
    }

    // Clear panel data response: BD 64 (Section 4.19)
    // Device echoes back the panel ID as confirmation.
    if (scriptCmd == 0xBD && subCmd == 0x64 && bytes.length >= 5) {
      final partId = (bytes[4] << 8) | bytes[3];
      return ClearPanelResponse(
        carPart: CarPart.fromValue(partId),
        partId: partId,
      );
    }

    // Alarm value responses: BD + (5E, 56, 68, 6C) (Sections 4.2–4.5, 4.10–4.13)
    if (scriptCmd == 0xBD &&
        (subCmd == 0x5E ||
            subCmd == 0x56 ||
            subCmd == 0x68 ||
            subCmd == 0x6C) &&
        bytes[0] == 0x03 &&
        bytes.length >= 6) {
      final value = _readInt16LE(bytes, 3);
      return AlarmValueResponse(subCommand: subCmd, value: value);
    }

    // Current panel / part selection: BD 70 (Section 4.21/4.22)
    // bytesCnt=0x03 means body is [0x70, uint16] — standard panel response
    if (scriptCmd == 0xBD && subCmd == 0x70 && bytes[0] == 0x03) {
      final partId = (bytes[4] << 8) | bytes[3];
      return CurrentPanelResponse(
        carPart: CarPart.fromValue(partId),
        partId: partId,
      );
    }

    // Fallback: BD 70 with unexpected bytesCnt — treat as part selection
    if (scriptCmd == 0xBD && subCmd == 0x70 && bytes.length >= 5) {
      final partId = (bytes[4] << 8) | bytes[3];
      return PartSelectionPacket(
        carPart: CarPart.fromValue(partId),
        partId: partId,
      );
    }

    // Data range response: BD 40 (Section 4.7)
    if (scriptCmd == 0xBD && subCmd == 0x40 && bytes.length >= 6) {
      return _parseDataRange(bytes);
    }

    // Panel data response: BD 67 (Section 4.20)
    if (scriptCmd == 0xBD && subCmd == 0x67 && bytes.length >= 6) {
      return _parsePanelData(bytes);
    }

    return UnknownPacket(rawBytes: bytes);
  }

  static MeasurementPacket _parseMeasurement(List<int> bytes) {
    // bytes[3..4] = partId (uint16 LE)
    final partId = (bytes[4] << 8) | bytes[3];
    final dataStart = bytes[5];
    final dataCnt = bytes[6];

    // bytes[7..9] = value (uint24 LE)
    final rawValue = (bytes[9] << 16) | (bytes[8] << 8) | bytes[7];
    final measurement = parseMeasurementValue(rawValue);

    return MeasurementPacket(
      carPart: CarPart.fromValue(partId),
      partId: partId,
      dataStart: dataStart,
      dataCnt: dataCnt,
      measurement: measurement,
    );
  }

  static DataRangeResponse _parseDataRange(List<int> bytes) {
    final totalValid = bytes[3];
    final measurements = <DeviceMeasurement>[];

    // Each measurement is 3 bytes (uint24), starting at index 4
    var offset = 4;
    while (offset + 2 < bytes.length - 2) {
      // -2 for CRC at the end
      final raw = (bytes[offset + 2] << 16) |
          (bytes[offset + 1] << 8) |
          bytes[offset];

      // Skip zero values (empty slots)
      if (raw != 0) {
        measurements.add(parseMeasurementValue(raw));
      }
      offset += 3;
    }

    return DataRangeResponse(
      totalValidCount: totalValid,
      measurements: measurements,
    );
  }

  static PanelDataResponse _parsePanelData(List<int> bytes) {
    final partId = (bytes[4] << 8) | bytes[3];
    final measurements = <DeviceMeasurement>[];

    // Group data starts at index 5, each uint24 (3 bytes)
    var offset = 5;
    while (offset + 2 < bytes.length - 2) {
      final raw = (bytes[offset + 2] << 16) |
          (bytes[offset + 1] << 8) |
          bytes[offset];

      if (raw != 0) {
        measurements.add(parseMeasurementValue(raw));
      }
      offset += 3;
    }

    return PanelDataResponse(
      carPart: CarPart.fromValue(partId),
      partId: partId,
      measurements: measurements,
    );
  }

  static bool _matchesBytes(List<int> data, List<int> prefix) {
    if (data.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }

  static int _readInt16LE(List<int> bytes, int offset) {
    final raw = (bytes[offset + 1] << 8) | bytes[offset];
    // Sign extend 16-bit to Dart int
    if (raw & 0x8000 != 0) return raw | ~0xFFFF;
    return raw;
  }
}
