part of '../team.dart';

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
  id: json['id'],
  owner: PlaceHolderModel.fromJsonAsIdAndName(json['owner']),
  name: json['name'],
  role: json['role'],
  isCurrent: json['current'],
  joinedAt: json['joined_at'] != null
      ? DateTime.parse(json['joined_at'])
      : null,
  permissions: json['permissions'] ?? [],
);

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
  'id': instance.id,
  'owner': instance.owner?.toJson(),
  'name': instance.name,
  'role': instance.role,
  'current': instance.isCurrent,
  'joined_at': instance.joinedAt?.toString(),
  'permissions': instance.permissions,
};
