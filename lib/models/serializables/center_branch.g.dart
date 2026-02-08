part of '../center_branch.dart';

CenterBranch _$CenterBranchFromJson(Map json) => CenterBranch(
  center: PlaceHolderModel.fromJson(json['center']),
  branch: PlaceHolderModel.fromJson(json['branch']),
  city: PlaceHolderModel.fromJson(json['city']),
  datetime: DateTime.parse(json['date']),
  date: json['datetime'],
);

Map<String, dynamic> _$CenterBranchToJson(CenterBranch instance) =>
    <String, dynamic>{
      'center': instance.center.toJson(),
      'branch': instance.branch?.toJson(),
      'city': instance.city?.toJson(),
      'date': instance.datetime?.toString(),
      'datetime': instance.date,
    };
