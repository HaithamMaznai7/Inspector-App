import 'package:json_annotation/json_annotation.dart';

part 'serializables/model.g.dart';

@JsonSerializable()
class PlaceHolderModel {
  num? id;
  String? label;
  String? avatar;

  PlaceHolderModel({this.id, this.label, this.avatar});

  factory PlaceHolderModel.fromJson(Map json) =>
      _$ModelFromJson(json);

  factory PlaceHolderModel.fromJsonAsIdAndName(Map<String, dynamic> json) =>
      _$ModelFromJsonAsIdAndName(json);

  Map<String, dynamic> toJson() => _$ModelToJson(this);

  Map<String, dynamic> toJsonAsIdAndName() => _$ModelToJsonAsIdAndName(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceHolderModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return label ?? '';
  }

  static PlaceHolderModel empty() {
    return PlaceHolderModel();
  }

  bool isEmpty() {
    return id == null;
  }

  bool isNotEmpty() {
    return !isEmpty();
  }
}
