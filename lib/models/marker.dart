import 'dart:io';
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

  Map<String, dynamic> toJson() => _$MarkerToJson(this);

  // WHAT: Accept any Map type (Map<dynamic, dynamic> or Map<String, dynamic>)
  // WHY: Hive deserializes all maps as Map<dynamic, dynamic>, not Map<String, dynamic>.
  //      When data is read from cache, the runtime type is _Map<dynamic, dynamic>,
  //      which cannot be implicitly cast to Map<String, dynamic>.
  // HOW: By accepting the base Map type, we avoid the type casting exception.
  //      The .g.dart file handles safe casting of individual fields internally.
  // EDGE CASES: Works for both fresh API responses (Map<String, dynamic>) and
  //             Hive cache reads (Map<dynamic, dynamic>).
  factory Marker.fromJson(Map json) => _$MarkerFromJson(json);
}
