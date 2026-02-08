import 'package:json_annotation/json_annotation.dart';
import 'placeholder_model.dart';

part 'serializables/center_branch.g.dart';

@JsonSerializable()
class CenterBranch {
  PlaceHolderModel center;
  PlaceHolderModel? branch;
  PlaceHolderModel? city;
  DateTime? datetime;
  String? date;

  CenterBranch({
    required this.center,
    this.branch,
    this.city,
    this.datetime,
    this.date,
  });

  factory CenterBranch.fromJson(Map json) =>
      _$CenterBranchFromJson(json);

  Map<String, dynamic> toJson() => _$CenterBranchToJson(this);
}
