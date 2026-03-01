import 'dart:io';
import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/models/point_type.dart';
import 'package:fahis_inspector/util/formatters/formatter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/point.g.dart';

@JsonSerializable()
class Point {
  int id;
  String title;
  String description;
  PointType category;

  PointStatus _status = PointStatus.none;

  PointStatus get status => _status;
  set setStatus(PointStatus? value) => _status = value ?? PointStatus.none;

  String? _note;

  String? get note => _note;
  set note(String? value) {
    _note = value ?? '';
  }

  String? _image;

  String? get image => EFormatter.formatImageUrl(_image);

  set image(String? value) {
    _image = value;
  }

  File? file;

  Point({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    String? status,
    String? note,
    String? image,
  }) {
    _status = PointStatus.set(status);
    _note = note ?? '';
    if (image != '' && image != null && image != 'null') {
      _image = image;
    }
  }

  static List<Point> setList(List<dynamic> points) =>
      points.map((point) => Point.fromJson(point)).toList();


  factory Point.fromJson(Map json) =>
      _$PointFromJson(json);
      
  Map<String, dynamic> toJson() => _$PointToJson(this);
}
