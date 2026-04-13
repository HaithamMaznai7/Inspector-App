import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/util/constants/enums.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'customer.dart';
import 'vehicle.dart';
import 'inspection_type.dart';
import 'center_branch.dart';
import 'placeholder_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/inspection.g.dart';

@JsonSerializable()
class Inspection {
  int id;
  String slug;
  Customer? customer;
  Vehicle? vehicle;
  CenterBranch? center;
  PlaceHolderModel? inspector;
  PlaceHolderModel? assignedTo;
  InspectionStage stage;
  UploadStatus uploadStatus = UploadStatus.notDownloaded;
  InspectionType? inspectionType;
  String note;
  String? rejectedNote;
  String? report;
  DateTime? inspectedAt;
  DateTime? reviewedAt;
  DateTime createdDate;

  Inspection({
    required this.id,
    required this.slug,
    required this.customer,
    this.vehicle,
    this.center,
    this.inspector,
    this.assignedTo,
    required this.stage,
    this.inspectionType,
    required this.uploadStatus,
    this.note = '',
    this.rejectedNote,
    this.report,
    this.inspectedAt,
    this.reviewedAt,
    required this.createdDate,
  });

  // Getters & Setters
  bool get hasDetails => inspectionType?.hasDetails ?? false;
  bool get hasPoints => inspectionType?.hasPoints ?? false;
  bool get hasPhotos => inspectionType?.hasPhotos ?? false;
  bool get hasBody => inspectionType?.hasBody ?? false;
  bool get hasPaintBody => inspectionType?.hasPaintBody ?? false;
  bool get hasObd => inspectionType?.hasObd ?? false;

  Inspection setDetails(Map map) {
    if (map['book'] is Map) {
      center = CenterBranch.fromJson(map['book']);
    }
    inspector = map['inspector'] != null
        ? PlaceHolderModel.fromJson(map['inspector'])
        : null;
    assignedTo = map['assigned'] != null
        ? PlaceHolderModel.fromJson(map['assigned'])
        : null;
    // status = Selection(value: map['status']['id'], label: map['status']['name']);
    stage = InspectionStage.fromJson(map['stage']);
    inspectionType = InspectionType.fromJson(map['inspection_type']);
    note = map['note'] ?? '';
    rejectedNote = map['rejected_note'];
    report = map['report'];
    inspectedAt = map['inspected_at'] != null
        ? DateTime.parse(map['inspected_at'])
        : null;
    reviewedAt = map['reviewed_at'] != null
        ? DateTime.parse(map['reviewed_at'])
        : null;

    return this;
  }

  // Serialization
  factory Inspection.fromJson(Map json) => _$InspectionFromJson(json);

  Map<String, dynamic> toJson() => _$InspectionToJson(this);

  static List<Inspection> setList(List inspections) =>
      inspections.map((inspection) => Inspection.fromJson(inspection)).toList();

  // factory Inspection.get(Box box, Inspection inspection) =>
  //     inspe.de(box.get('Inspection-$slug'));

  void saveDetails(Box box) {
    box.put('Inspection-$slug', toJson);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Inspection && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
