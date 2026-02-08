part of '../placeholder_model.dart';

PlaceHolderModel _$ModelFromJson(Map json) =>
    json['id'] != null
    ? PlaceHolderModel(
        id: json['id'],
        label: json['label'],
        avatar: json['avatar'],
      )
    : PlaceHolderModel.empty();

PlaceHolderModel _$ModelFromJsonAsIdAndName(Map<String, dynamic> json) =>
    json['id'] != null
    ? PlaceHolderModel(
        id: json['id'],
        label: json['name'],
        avatar: json['avatar'],
      )
    : PlaceHolderModel.empty();

Map<String, dynamic> _$ModelToJson(PlaceHolderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'avatar': instance.avatar,
    };

Map<String, dynamic> _$ModelToJsonAsIdAndName(PlaceHolderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.label,
      'avatar': instance.avatar,
    };
