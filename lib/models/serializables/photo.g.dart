part of '../photo.dart';

Photo _$PhotoFromJson(Map json) => Photo(
    id: json['id'],
    title: json['title'],
    type: json['type'],
    image: json['image'],
);

Map<String, dynamic> _$PhotoToJson(Photo instance) =>
  <String, dynamic> {
    'id': instance.id,
    'title': instance.title,
    'type': instance.type,
    'image': instance.image,
  };