import 'dart:io';

import 'package:fahis_inspector/util/formatters/formatter.dart';

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

  factory Photo.set(Map point) {
    return Photo(
      id: point['id'],
      title: point['title'],
      type: point['type'],
      image: point['image'],
    );
  }

  static List<Photo> setList(List<dynamic> photos) =>
      photos.map((photo) => Photo.set(photo)).toList();

  toJson() => {'id': id, 'title': title, 'type': type, 'image': image};
}
