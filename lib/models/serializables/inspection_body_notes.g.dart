part of '../inspection_body_notes.dart';

CarBody _$CarBodyFromJson(Map json) => CarBody(
  id: json['id'],
  part: BodyPart.set(json['type']),
  image: json['image'],
  notes: (json['notes'] as List)
      .map((marker) => Marker.fromJson(marker))
      .toList(),
);

Map<String, dynamic> _$CarBodyToJson(CarBody instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.part.value,
  'image': instance.image,
  'notes': instance.notes.map((marker) => marker.toJson()).toList()
};
