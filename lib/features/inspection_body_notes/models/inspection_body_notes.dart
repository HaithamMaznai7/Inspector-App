import 'dart:io';
import 'package:fahis_inspector/features/inspections/models/menu_item.dart';
import 'package:get/get_utils/get_utils.dart';

class CarBody {
  int id;
  BodyPart part;
  String image;
  List<Marker> notes;

  CarBody({
    required this.id,
    required this.part,
    required this.image,
    this.notes = const [],
  });

  toJson() => {'id': id, 'type': part.value, 'image': image, 'notes': notes.map((marker) => marker.toJson()).toList()};

  factory CarBody.set(Map<String, dynamic> bodySide) => CarBody(
    id: bodySide['id'],
    part: BodyPart.set(bodySide['type']),
    image: bodySide['image'],
    notes: (bodySide['notes'] as List)
        .map((marker) => Marker.set(marker as Map))
        .toList(),
  );

  static List<CarBody> setList(List bodySides) =>
      bodySides.map((bodySide) => CarBody.set(bodySide)).toList();
}

class Marker {
  int id;
  String? note;
  double dx;
  double dy;
  MenuItem? type;
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

  factory Marker.set(Map marker) {
    return Marker(
      id: marker['id'],
      note: marker['note'],
      dx: double.parse(marker['dx']),
      dy: double.parse(marker['dy']),
      type: MenuItem(id: marker['type']['id'], title: marker['type']['name']),
      image: marker['photo'],
    );
  }

  toJson() => {
    'id': id,
    'note': note,
    'dx': dx.toString(),
    'dy': dy.toString(),
    'type': type != null ? {'id': type?.id, 'name': type?.title} : null,
    'photo': image,
  };
}

enum BodyPart {
  right,
  left,
  front,
  back,
  top,
  interior;

  static BodyPart set(String bodyPart) {
    switch (bodyPart) {
      case 'Top':
        return BodyPart.top;
      case 'Left':
        return BodyPart.left;
      case 'Right':
        return BodyPart.right;
      case 'Front':
        return BodyPart.front;
      case 'Back':
        return BodyPart.back;
      case 'Interior':
        return BodyPart.interior;
      default:
        return BodyPart.interior;
    }
  }

  String get value {
    switch (this) {
      case BodyPart.top:
        return 'Top';
      case BodyPart.left:
        return 'Left';
      case BodyPart.right:
        return 'Right';
      case BodyPart.front:
        return 'Front';
      case BodyPart.back:
        return 'Back';
      case BodyPart.interior:
        return 'Interior';
    }
  }

  String label() {
    switch (this) {
      case BodyPart.top:
        return 'Top'.tr;
      case BodyPart.left:
        return 'Left'.tr;
      case BodyPart.right:
        return 'Right'.tr;
      case BodyPart.front:
        return 'Front'.tr;
      case BodyPart.back:
        return 'Back'.tr;
      case BodyPart.interior:
        return 'Interior'.tr;
    }
  }
}
