import 'package:json_annotation/json_annotation.dart';

part 'serializables/point_type.g.dart';

@JsonSerializable()
class PointType {
  int id;
  String title;
  String icon;

  PointType({required this.id, required this.title, required this.icon});

  factory PointType.fromJson(Map json) =>
      _$PointTypeFromJson(json);
      
  Map<String, dynamic> toJson() => _$PointTypeToJson(this);
}
