part of '../inspection_type.dart';

InspectionType _$InspectionTypeFromJson(Map json) => InspectionType(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    hasPoints: json['has_points'] == 1,
    hasPhotos: json['has_photos']  == 1,
    hasBody: json['has_body'] == 1,
    hasObd: json['has_obd'] == 1,
    hasDetails: json['has_details'] == 1,
    hasPaintBody: json['has_body_points'] == 1
);

Map<String, dynamic> _$InspectionTypeToJson(InspectionType instance) => <String, dynamic>{
    'id': instance.id,
    'title': instance.title,
    'description': instance.description,
    'has_points': instance.hasPoints,
    'has_photos': instance.hasPhotos,
    'has_body': instance.hasBody,
    'has_obd': instance.hasObd,
    'has_details': instance.hasDetails,
    'has_body_points': instance.hasPaintBody,
};
