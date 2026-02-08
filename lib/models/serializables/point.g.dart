part of '../point.dart';

Point _$PointFromJson(Map json) => Point(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    category: PointType.fromJson(json['type']),
    status: json['status'],
    note: json['note'],
    image: json['image'],
);

Map<String, dynamic> _$PointToJson(Point instance) =>
  <String, dynamic> {
    'id': instance.id,
    'title': instance.title,
    'description': instance.description,
    'type': instance.category.toJson(),
    'status': instance.status.value,
    'note': instance.note,
    'image': instance.image,
  };