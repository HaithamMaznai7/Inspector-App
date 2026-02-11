part of '../marker.dart';

// WHAT: Deserialize a JSON map into a Marker object with safe type handling.
// WHY: The 'type' field from the API is a nested Map like {"id": "1"}, but:
//       1. It can be null (as seen in debug screenshots where photo is null)
//       2. When read from Hive cache, it's Map<dynamic, dynamic>, not Map<String, dynamic>
// HOW: We use null-aware access (?[]) on the 'type' field to prevent null dereference.
//      We also cast dx/dy to double explicitly since Hive may store them as num.
// EDGE CASES:
//   - type is null → type field becomes null (safe)
//   - type is a Map with 'id' → extracts id as String
//   - dx/dy stored as int by Hive → .toDouble() converts safely
Marker _$MarkerFromJson(Map json) => Marker(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      note: json['note']?.toString(),
      dx: (json['dx'] is num) ? (json['dx'] as num).toDouble() : double.tryParse(json['dx'].toString()) ?? 0.0,
      dy: (json['dy'] is num) ? (json['dy'] as num).toDouble() : double.tryParse(json['dy'].toString()) ?? 0.0,
      type: json['type'] != null ? (json['type']['id'])?.toString() : null,
      image: json['photo']?.toString(),
    );

Map<String, dynamic> _$MarkerToJson(Marker instance) => <String, dynamic>{
  'id': instance.id,
  'note': instance.note,
  'dx': instance.dx,
  'dy': instance.dy,
  'type': {
    'id': instance.type,
  },
  'photo': instance.image,
};
