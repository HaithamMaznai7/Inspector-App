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

  File? file;

  // Transient: true while a picked image is queued offline and has not been
  // POSTed yet. Never serialized — set at runtime only.
  bool isPending;

  Photo({
    required this.id,
    required this.title,
    required this.type,
    String? image,
    this.isPending = false,
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
