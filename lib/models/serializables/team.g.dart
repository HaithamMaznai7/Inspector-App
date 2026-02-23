part of '../team.dart';

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
  id: json['id'],
  owner: json['owner'] != null
      ? PlaceHolderModel.fromJsonAsIdAndName(Map<String, dynamic>.from(json['owner']))
      : null,
  type: json['type'],
  name: json['name'],
  role: json['role'],
  isCurrent: json['current'] ?? false,
  joinedAt: json['joined_at'] != null
      ? DateTime.parse(json['joined_at'])
      : null,
  invitedAt: json['invited_at'] != null
      ? DateTime.parse(json['invited_at'])
      : null,
  permissions: json['permissions'] ?? [],
);

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
  'id': instance.id,
  'owner': instance.owner?.toJsonAsIdAndName(),
  'type': instance.type,
  'name': instance.name,
  'role': instance.role,
  'current': instance.isCurrent,
  'joined_at': instance.joinedAt?.toIso8601String(),
  'invited_at': instance.invitedAt?.toIso8601String(),
  'permissions': instance.permissions,
};
