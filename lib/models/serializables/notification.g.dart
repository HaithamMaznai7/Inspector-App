part of '../notification.dart';

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: json['id'],
  type: json['type'],
  title: json['data']['title'],
  description: json['data']['description'],
  url: json['data']['url'],
  page: json['data']['page'],
  readAt: json['read_at'] == null ? null : DateTime.tryParse(json['read_at'].toString()),
  createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
  <String, dynamic> {
    'id': instance.id,
    'type': instance.type,
    'data': {
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'page': instance.page,
    },
    'read_at': instance.readAt.toString(),
    'created_at': instance.createdAt.toString(),
  };
