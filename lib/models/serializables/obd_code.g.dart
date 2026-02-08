part of '../obd_code.dart';

OBDCode _$OBDCodeFromJson(Map json) => OBDCode(
    id: json['id'],
    code: json['code'],
    description: json['description'],
);

Map<String, dynamic> _$OBDCodeToJson(OBDCode instance) =>
  <String, dynamic> {
    'id': instance.id,
    'code': instance.code,
    'description': instance.description,
  };