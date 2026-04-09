import 'package:fahis_inspector/paint_gauge/protocol/models.dart';

/// Backend entity for a paint gauge panel row.
///
/// Represents the server-side state of a single panel. The backend
/// is the source of truth for the panel list and saved measurements.
class PaintPanel {
  final int id;
  final String name;
  final String partCode; // hex string, e.g. "0x8F10"
  double? thickness; // average thickness from backend
  String? substrate;
  int measurementCount;

  PaintPanel({
    required this.id,
    required this.name,
    required this.partCode,
    this.thickness,
    this.substrate,
    this.measurementCount = 0,
  });

  factory PaintPanel.fromJson(Map<String, dynamic> json) => PaintPanel(
    id: json['id'] as int,
    name: json['name'] as String,
    partCode: json['part_code'] as String,
    thickness: (json['thickness'] as num?)?.toDouble(),
    substrate: json['substrate'] as String?,
    measurementCount: json['measurementCount'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'part_code': partCode,
    'thickness': thickness,
    'substrate': substrate,
    'measurementCount': measurementCount,
  };

  /// Match this backend panel to a [CarPart] enum by hex code.
  ///
  /// Uses [int.parse] instead of [int.tryParse] because Dart's tryParse
  /// does not handle hex-prefixed strings like "0x0010".
  CarPart? get carPart {
    try {
      final intValue = int.parse(partCode);
      return CarPart.fromValue(intValue);
    } catch (_) {
      return null;
    }
  }
}
