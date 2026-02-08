part of '../marker.dart';

Marker _$MarkerFromJson(Map json) => Marker(
      id: json['id'],
      note: json['note'],
      dx: json['dx'],
      dy: json['dy'],
      type: (json['type']['id']).toString(),
      image: json['photo'],
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
