/// Vehicle body parts enumeration from protocol document (Section 4.19/4.20).
enum CarPart {
  frontHatch(0x8010, 'Hood'),
  flWing(0x0010, 'Left Front Fender'),
  lAColumn(0x0031, 'Left A-pillar'),
  flDoor(0x0020, 'Left Front Door'),
  lBColumn(0x0832, 'Left B-pillar'),
  blDoor(0x0F20, 'Left Rear Door'),
  lCColumn(0x0F33, 'Left C-pillar'),
  blWing(0x0F10, 'Left Rear Fender'),
  lDColumn(0x0F34, 'Left D-pillar'),
  trunkCover(0x8F10, 'Trunk Cover'),
  rDColumn(0xFF34, 'Right D-pillar'),
  brWing(0xFF10, 'Right Rear Fender'),
  rCColumn(0xFF33, 'Right C-pillar'),
  brDoor(0xFF20, 'Right Rear Door'),
  rBColumn(0xF832, 'Right B-pillar'),
  frDoor(0xF020, 'Right Front Door'),
  rAColumn(0xF031, 'Right A-pillar'),
  frWing(0xF010, 'Right Front Fender'),
  roof(0x8810, 'Roof');

  const CarPart(this.value, this.label);
  final int value;
  final String label;

  static CarPart? fromValue(int value) {
    for (final part in CarPart.values) {
      if (part.value == value) return part;
    }
    return null;
  }
}

/// Substrate type encoded in the lowest 2 bits of measurement data.
enum SubstrateType {
  fe(0x01, 'Fe'),
  nfe(0x02, 'NFe'),
  metalPutty(0x03, 'Metal Putty');

  const SubstrateType(this.value, this.label);
  final int value;
  final String label;

  static SubstrateType? fromValue(int value) {
    for (final s in SubstrateType.values) {
      if (s.value == value) return s;
    }
    return null;
  }
}

/// Measurement mode of the thickness gauge (Section 4.17/4.18).
enum MeasurementMode {
  carHandy(0x01, 'CarHandy'),
  carPro(0x02, 'CarPro');

  const MeasurementMode(this.value, this.label);
  final int value;
  final String label;

  static MeasurementMode? fromValue(int value) {
    for (final m in MeasurementMode.values) {
      if (m.value == value) return m;
    }
    return null;
  }
}

/// Stores all readings for a single body part (up to 6 per panel).
class PartMeasurement {
  final CarPart part;

  /// Up to 6 readings from the device (CarPro per-panel group).
  /// Ordered oldest → newest; newest is always `readings.last`.
  final List<double> readings;

  /// Substrate of the most recent measurement.
  SubstrateType? substrate;

  /// Number of readings recorded in the current session.
  /// Equals [readings.length] — never sourced from device memory.
  int measurementCount;

  PartMeasurement({
    required this.part,
    List<double>? readings,
    this.substrate,
    this.measurementCount = 0,
  }) : readings = readings ?? [];

  /// True if at least one reading exists.
  bool get hasMeasurement => readings.isNotEmpty;

  /// Most recent reading, or null if none.
  double? get latestReading => readings.isEmpty ? null : readings.last;

  /// Average of all stored readings, rounded per Section 6 display rules.
  double? get average {
    if (readings.isEmpty) return null;
    final sum = readings.reduce((a, b) => a + b);
    final avg = sum / readings.length;
    return avg.abs() < 99.95
        ? double.parse(avg.toStringAsFixed(1))
        : avg.round().toDouble();
  }

  /// Update from a live BD 52 measurement packet received in the current session.
  ///
  /// Adds [newThickness] to [readings] (evicting the oldest if already at 6).
  /// [measurementCount] reflects the session reading count, not device memory.
  void update(double newThickness, SubstrateType newSubstrate) {
    if (readings.length >= 6) {
      // Keep readings 1–5 locked; only overwrite the 6th slot.
      readings[5] = newThickness;
    } else {
      readings.add(newThickness);
    }
    substrate = newSubstrate;
    measurementCount = readings.length;
  }

  /// Populate readings from a `getPanelData` (BD 67) response.
  ///
  /// Replaces any existing readings; substrate is taken from the last entry.
  void setFromPanelData(List<DeviceMeasurement> measurements) {
    readings.clear();
    for (final m in measurements.take(6)) {
      readings.add(m.thickness);
    }
    if (measurements.isNotEmpty) {
      substrate = measurements.last.substrate;
    }
    measurementCount = readings.length;
  }

  /// Clear all readings — call only after a successful `clearPanelData` command.
  void clear() {
    readings.clear();
    substrate = null;
    measurementCount = 0;
  }
}

/// A single decoded measurement value from the device.
class DeviceMeasurement {
  final double thickness;
  final SubstrateType substrate;
  final int rawValue;

  const DeviceMeasurement({
    required this.thickness,
    required this.substrate,
    required this.rawValue,
  });
}

/// Alarm configuration (Sections 4.1–4.5, 4.9–4.13).
class AlarmSettings {
  final bool enabled;
  final int upperLimit;
  final int lowerLimit;
  final int seriousUpperLimit;
  final int seriousLowerLimit;

  const AlarmSettings({
    required this.enabled,
    required this.upperLimit,
    required this.lowerLimit,
    required this.seriousUpperLimit,
    required this.seriousLowerLimit,
  });
}

/// Parses a raw uint24 measurement value into thickness + substrate.
///
/// Protocol Section 5/6: little-endian uint24, lowest 2 bits = substrate,
/// remaining bits / 256.0 = thickness. Negative values use sign extension.
/// Display: |value| < 99.95 -> 1 decimal; >= 99.95 -> integer.
DeviceMeasurement parseMeasurementValue(int rawValue) {
  final substrateBits = rawValue & 0x03;
  final substrate = SubstrateType.fromValue(substrateBits) ?? SubstrateType.fe;

  final isNegative = (rawValue & 0x800000) != 0;

  double thicknessValue;
  if (isNegative) {
    final signedValue = rawValue | 0xFF000000;
    final int32Value = signedValue.toSigned(32);
    thicknessValue = int32Value / 256.0;
  } else {
    thicknessValue = rawValue / 256.0;
  }

  // Round per protocol Section 6
  if (thicknessValue.abs() < 99.95) {
    thicknessValue = double.parse(thicknessValue.toStringAsFixed(1));
  } else {
    thicknessValue = thicknessValue.round().toDouble();
  }

  return DeviceMeasurement(
    thickness: thicknessValue,
    substrate: substrate,
    rawValue: rawValue,
  );
}
