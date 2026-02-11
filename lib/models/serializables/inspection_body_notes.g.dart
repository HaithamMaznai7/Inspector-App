part of '../inspection_body_notes.dart';

// WHAT: Deserialize a JSON map into a CarBody object.
// WHY: When data comes from Hive cache, all nested maps are Map<dynamic, dynamic>.
//      The 'notes' field is a List of maps, each representing a Marker.
//      Without explicit casting, Marker.fromJson receives Map<dynamic, dynamic>
//      which caused the original crash.
// HOW: We cast each marker map using Map<String, dynamic>.from() to ensure
//      type safety before passing to Marker.fromJson.
//      We also handle null/empty 'notes' gracefully.
// EDGE CASES:
//   - notes is null → defaults to empty list
//   - notes contains maps from Hive (Map<dynamic, dynamic>) → safely cast
//   - id could be int or String from different sources → handled
// PERFORMANCE: Map.from() creates a shallow copy; negligible cost for small marker maps.
CarBody _$CarBodyFromJson(Map json) => CarBody(
  id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
  part: BodyPart.set(json['type']?.toString() ?? 'Interior'),
  image: json['image']?.toString() ?? '',
  notes: json['notes'] != null
      ? (json['notes'] as List)
          .map((marker) => Marker.fromJson(
                // Deep-cast each marker map to Map<String, dynamic>
                // to handle Hive's Map<dynamic, dynamic> deserialization
                Map<String, dynamic>.from(marker as Map),
              ))
          .toList()
      : [],
);

Map<String, dynamic> _$CarBodyToJson(CarBody instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.part.value,
  'image': instance.image,
  'notes': instance.notes.map((marker) => marker.toJson()).toList()
};
