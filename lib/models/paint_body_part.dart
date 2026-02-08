import 'package:fahis_inspector/enums/car_part.dart';
import 'package:fahis_inspector/resources/inspection_paint_body_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaintBodyPart {
  int id;
  String inspection;
  String name;
  double? thickness;
  String? substrate;
  DateTime? timestamp;
  int measurementCount;
  CarPart? part;
  
  PaintBodyPart({
    required this.id,
    required this.inspection,
    required this.name,
    required this.part,
    this.thickness,
    this.substrate,
    this.timestamp,
    this.measurementCount = 0,
  });

  static Future<InspectionPaintBodyRepository> getRepository(String slug) async {
    final box = await Hive.openBox(InspectionPaintBodyRepository.boxKey);
    return InspectionPaintBodyRepository(box: box, slug: slug);
  }

  toJson() => {
    'id': id,
    'inspection': inspection,
    'name': name,
    'slug': part?.value ,
    'thickness': thickness,
    'substrate': substrate,
    'measurementCount': measurementCount
  };

  bool get hasMeasurement => thickness != null;

  Future<List<PaintBodyPart>> update(double newThickness, String newSubstrate) async {
    thickness = newThickness;
    substrate = newSubstrate;
    timestamp = DateTime.now();
    measurementCount++;
    final repository = await PaintBodyPart.getRepository(inspection);
    return await repository.update(this);
  }

  factory PaintBodyPart.set(Map<String, dynamic> code) {
    return PaintBodyPart(
      id: code['id'],
      inspection: code['inspection'],
      name: code['name'],
      part: CarPart.fromValue(code['slug']),
      thickness: code['thickness'],
      substrate: code['substrate'],
      timestamp: DateTime.now(),
      measurementCount: code['measurementCount'],
    );
  }

  static List<PaintBodyPart> setList(List parts) => parts.isEmpty
      ? []
      : parts.map((part) => PaintBodyPart.set(part)).toList();
}
