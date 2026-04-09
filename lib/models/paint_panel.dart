/// Parses a thickness value from the backend, which may arrive as
/// a [num], a [String], or `null` depending on backend state.
double? parseThickness(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Backend entity for a paint gauge panel row.
///
/// Holds only the server-side saved values for a panel.
/// Panel identity, order, labels, and BLE mapping come from the
/// app-side `CarPart` enum — matched via `CarPart.backendId == id`.
class PaintPanel {
  final int id;
  final String name;
  final String partCode;
  double? thickness;
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
    thickness: parseThickness(json['thickness']),
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
}
