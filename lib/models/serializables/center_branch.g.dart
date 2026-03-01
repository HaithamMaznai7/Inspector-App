part of '../center_branch.dart';

CenterBranch _$CenterBranchFromJson(Map json) => CenterBranch(
  center: json['center'] != null
      ? PlaceHolderModel.fromJson(json['center'])
      : PlaceHolderModel.empty(),
  branch: json['branch'] != null
      ? PlaceHolderModel.fromJson(json['branch'])
      : null,
  city: json['city'] != null
      ? PlaceHolderModel.fromJson(json['city'])
      : null,
  datetime: json['date'] != null ? DateTime.tryParse(json['date']) : null,
  date: json['date'],
);

Map<String, dynamic> _$CenterBranchToJson(CenterBranch instance) =>
    <String, dynamic>{
      'center': instance.center.toJson(),
      'branch': instance.branch?.toJson(),
      'city': instance.city?.toJson(),
      'date': instance.datetime?.toString(),
      'datetime': instance.date,
    };
