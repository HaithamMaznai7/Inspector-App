part of '../point_type.dart';

PointType _$PointTypeFromJson(Map json) => PointType(
    id: json['id'],
    title: json['title'],
    icon: json['icon'],
);

Map<String, dynamic> _$PointTypeToJson(PointType instance) =>
  <String, dynamic> {
    'id': instance.id,
    'title': instance.title,
    'icon': instance.icon,
  };