import 'dart:io';
import 'package:fahis_inspector/util/formatters/formatter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/photo.g.dart';

@JsonSerializable()
class Photo {
  int id;
  String title;
  String type;

  String? _image;

  String? get image => EFormatter.formatImageUrl(_image);
  set setImage(String? value) {
    _image = value;
  }

  File? _file;

  File? get file => _file;

  set file(File? value) {
    _file = value;
  }

  Photo({
    required this.id,
    required this.title,
    required this.type,
    String? image,
  }) {
    if (image != '' && image != null && image != 'null') {
      _image = image;
    }
  }

  static List<Photo> setList(List<dynamic> photos) =>
      photos.map((photo) => Photo.fromJson(photo)).toList();
  
  factory Photo.fromJson(Map json) =>
      _$PhotoFromJson(json);
      
  Map<String, dynamic> toJson() => _$PhotoToJson(this);
}
