import 'package:json_annotation/json_annotation.dart';

part 'serializables/inspection_type.g.dart';

@JsonSerializable()
class InspectionType {
  int id;
  String title;
  String description;
  bool hasDetails;
  bool hasPoints;
  bool hasPhotos;
  bool hasBody;
  bool hasPaintBody;
  bool hasObd;

  InspectionType({
    required this.id,
    required this.title,
    this.description = '',
    this.hasDetails = false,
    this.hasPoints = false,
    this.hasPhotos = false,
    this.hasBody = false,
    this.hasObd = false,
    this.hasPaintBody = false,
  });

  factory InspectionType.fromJson(Map json) => _$InspectionTypeFromJson(json);

  Map<String,dynamic> toJson() => _$InspectionTypeToJson(this);
}