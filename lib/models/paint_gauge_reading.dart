/// A single panel's paint thickness measurement data from one inspection session.
///
/// Designed for detailed client reporting — includes individual readings,
/// statistical summary, substrate type, and audit timestamps.
class PaintGaugeReading {
  /// Human-readable panel name (e.g. "Hood", "Left Front Door").
  final String panelName;

  /// Protocol hex code for the panel (e.g. "0x8010" for Hood).
  final String panelCode;

  /// Substrate material detected: "Fe", "NFe", or "Metal Putty".
  /// Metal Putty is a red flag for undisclosed body repair.
  final String substrate;

  /// Up to 6 individual thickness values in μm, ordered oldest → newest.
  /// Stored individually (not just average) so the report can show
  /// measurement consistency — high variance suggests panel repair.
  final List<double> readings;

  /// Arithmetic mean of [readings].
  final double? averageThickness;

  /// Lowest reading — flags suspiciously thin panels (poor repaint).
  final double? minThickness;

  /// Highest reading — flags suspiciously thick panels (body filler).
  final double? maxThickness;

  /// Number of readings taken (0-6).
  final int measurementCount;

  /// True if all 6 reading slots are filled.
  final bool isComplete;

  /// When the first reading was recorded in this session.
  final DateTime? firstReadingAt;

  /// When the most recent reading was recorded in this session.
  final DateTime? lastReadingAt;

  const PaintGaugeReading({
    required this.panelName,
    required this.panelCode,
    required this.substrate,
    required this.readings,
    this.averageThickness,
    this.minThickness,
    this.maxThickness,
    required this.measurementCount,
    required this.isComplete,
    this.firstReadingAt,
    this.lastReadingAt,
  });

  /// Creates a reading from raw measurement data.
  factory PaintGaugeReading.fromMeasurements({
    required String panelName,
    required String panelCode,
    required String substrate,
    required List<double> readings,
    DateTime? firstReadingAt,
    DateTime? lastReadingAt,
  }) {
    double? avg, min, max;
    if (readings.isNotEmpty) {
      final sum = readings.reduce((a, b) => a + b);
      final rawAvg = sum / readings.length;
      avg = rawAvg.abs() < 99.95
          ? double.parse(rawAvg.toStringAsFixed(1))
          : rawAvg.round().toDouble();
      min = readings.reduce((a, b) => a < b ? a : b);
      max = readings.reduce((a, b) => a > b ? a : b);
    }

    return PaintGaugeReading(
      panelName: panelName,
      panelCode: panelCode,
      substrate: substrate,
      readings: List.unmodifiable(readings),
      averageThickness: avg,
      minThickness: min,
      maxThickness: max,
      measurementCount: readings.length,
      isComplete: readings.length >= 6,
      firstReadingAt: firstReadingAt,
      lastReadingAt: lastReadingAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'panelName': panelName,
        'panelCode': panelCode,
        'substrate': substrate,
        'readings': readings,
        'averageThickness': averageThickness,
        'minThickness': minThickness,
        'maxThickness': maxThickness,
        'measurementCount': measurementCount,
        'isComplete': isComplete,
        'firstReadingAt': firstReadingAt?.toIso8601String(),
        'lastReadingAt': lastReadingAt?.toIso8601String(),
      };

  factory PaintGaugeReading.fromJson(Map<String, dynamic> json) {
    return PaintGaugeReading(
      panelName: json['panelName'] as String,
      panelCode: json['panelCode'] as String,
      substrate: json['substrate'] as String,
      readings: (json['readings'] as List).cast<double>(),
      averageThickness: json['averageThickness'] as double?,
      minThickness: json['minThickness'] as double?,
      maxThickness: json['maxThickness'] as double?,
      measurementCount: json['measurementCount'] as int,
      isComplete: json['isComplete'] as bool,
      firstReadingAt: json['firstReadingAt'] != null
          ? DateTime.parse(json['firstReadingAt'] as String)
          : null,
      lastReadingAt: json['lastReadingAt'] != null
          ? DateTime.parse(json['lastReadingAt'] as String)
          : null,
    );
  }
}
