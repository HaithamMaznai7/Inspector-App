
import 'dart:io';
import 'package:fahis_inspector/models/menu_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/marker.g.dart';

@JsonSerializable()
class Marker {
  int id;
  String? note;
  double dx;
  double dy;
  String? type;
  String? image;
  File? _file;

  File? get file => _file;

  set file(File? value) {
    _file = value;
  }
  
  Marker({
    required this.id,
    this.note,
    required this.dx,
    required this.dy,
    this.type,
    this.image,
  });

  Map<String,dynamic> toJson() => _$MarkerToJson(this);

  factory Marker.fromJson(Map<String, dynamic> json) => _$MarkerFromJson(json);
}