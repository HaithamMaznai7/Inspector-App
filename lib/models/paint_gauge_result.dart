import 'package:fahis_inspector/models/paint_gauge_reading.dart';

/// Container for all paint gauge measurements from a single inspection session.
///
/// Holds per-panel [PaintGaugeReading] data plus session-level metadata
/// for traceability and audit.
class PaintGaugeResult {
  /// Inspection identifier — links this result to the inspection.
  final String inspectionSlug;

  /// Per-panel readings keyed by panel hex code (e.g. "0x8010").
  final Map<String, PaintGaugeReading> panels;

  /// How many of the 19 panels have at least one reading.
  final int totalPanelsMeasured;

  /// Sum of all individual readings across all panels.
  final int totalReadings;

  /// When the inspector started measuring (first BLE connection or first reading).
  final DateTime sessionStartedAt;

  /// When the session ended (disconnect or step navigation).
  final DateTime? sessionEndedAt;

  /// BLE device advertised name — for traceability in reports.
  final String? deviceName;

  /// BLE device MAC address — for traceability in reports.
  final String? deviceMac;

  const PaintGaugeResult({
    required this.inspectionSlug,
    required this.panels,
    required this.totalPanelsMeasured,
    required this.totalReadings,
    required this.sessionStartedAt,
    this.sessionEndedAt,
    this.deviceName,
    this.deviceMac,
  });

  /// Creates a result from a map of panel readings.
  factory PaintGaugeResult.fromReadings({
    required String inspectionSlug,
    required Map<String, PaintGaugeReading> panels,
    required DateTime sessionStartedAt,
    DateTime? sessionEndedAt,
    String? deviceName,
    String? deviceMac,
  }) {
    final measured =
        panels.values.where((r) => r.measurementCount > 0).length;
    final total =
        panels.values.fold<int>(0, (sum, r) => sum + r.measurementCount);

    return PaintGaugeResult(
      inspectionSlug: inspectionSlug,
      panels: panels,
      totalPanelsMeasured: measured,
      totalReadings: total,
      sessionStartedAt: sessionStartedAt,
      sessionEndedAt: sessionEndedAt,
      deviceName: deviceName,
      deviceMac: deviceMac,
    );
  }

  /// Serializes for backend submission and Hive persistence.
  // TODO: Backend integration — POST /inspector/inspections/{slug}/paint-gauge
  // TODO: Backend should accept this JSON structure
  Map<String, dynamic> toJson() => {
        'inspectionSlug': inspectionSlug,
        'panels':
            panels.map((key, value) => MapEntry(key, value.toJson())),
        'totalPanelsMeasured': totalPanelsMeasured,
        'totalReadings': totalReadings,
        'sessionStartedAt': sessionStartedAt.toIso8601String(),
        'sessionEndedAt': sessionEndedAt?.toIso8601String(),
        'deviceName': deviceName,
        'deviceMac': deviceMac,
      };

  factory PaintGaugeResult.fromJson(Map<String, dynamic> json) {
    final panelsMap = (json['panels'] as Map).map(
      (key, value) => MapEntry(
        key as String,
        PaintGaugeReading.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );

    return PaintGaugeResult(
      inspectionSlug: json['inspectionSlug'] as String,
      panels: panelsMap,
      totalPanelsMeasured: json['totalPanelsMeasured'] as int,
      totalReadings: json['totalReadings'] as int,
      sessionStartedAt: DateTime.parse(json['sessionStartedAt'] as String),
      sessionEndedAt: json['sessionEndedAt'] != null
          ? DateTime.parse(json['sessionEndedAt'] as String)
          : null,
      deviceName: json['deviceName'] as String?,
      deviceMac: json['deviceMac'] as String?,
    );
  }
}
