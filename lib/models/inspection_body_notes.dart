import 'package:fahis_inspector/enums/body_part.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:json_annotation/json_annotation.dart';
part 'serializables/inspection_body_notes.g.dart';

@JsonSerializable()
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

  Map<String,dynamic> toJson() => _$CarBodyToJson(this);

  factory CarBody.fromJson(Map json) => _$CarBodyFromJson(json);

  static List<CarBody> setList(List bodySides) =>
      bodySides.map((bodySide) => CarBody.fromJson(bodySide)).toList();
}