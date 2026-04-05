part of '../inspection_type.dart';

bool _toBool(dynamic value) => value == true || value == 1;

InspectionType _$InspectionTypeFromJson(Map json) => InspectionType(
  id: json['id'],
  title: json['title'],
  description: json['description'],
  hasPoints: _toBool(json['has_points']),
  hasPhotos: _toBool(json['has_photos']),
  hasBody: _toBool(json['has_body']),
  hasObd: _toBool(json['has_obd']),
  hasDetails: _toBool(json['has_details']),
  // TODO: restore backend value → _toBool(json['has_body_points'])
  hasPaintBody: true,
);

Map<String, dynamic> _$InspectionTypeToJson(InspectionType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'has_points': instance.hasPoints,
      'has_photos': instance.hasPhotos,
      'has_body': instance.hasBody,
      'has_obd': instance.hasObd,
      'has_details': instance.hasDetails,
      'has_paint_body': instance.hasPaintBody,
    };
