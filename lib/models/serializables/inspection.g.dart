part of '../inspection.dart';

Inspection _$InspectionFromJson(Map json) => Inspection(
  id: json['id'],
  slug: json['slug'],
  customer: Customer.fromJson(json['customer']),
  vehicle: Vehicle.fromJson(json['vehicle']),
  stage: InspectionStage.fromJson(json['stage']) ,
  uploadStatus: UploadStatus.live,
  createdDate: DateTime.parse(json['created_at']),
  center: json['book'] != null && json['book'] is Map
      ? CenterBranch.fromJson(json['book'])
      : null,
  inspector: json['inspector'] != null
      ? PlaceHolderModel.fromJson(json['inspector'])
      : null,
  assignedTo: json['assigned'] != null
      ? PlaceHolderModel.fromJson(json['assigned'])
      : null,
  inspectionType: json['inspection_type'] != null
      ? InspectionType.fromJson(json['inspection_type'])
      : null,
  note: json['note'] ?? '',
  rejectedNote: json['rejected_note'],
  report: json['report'],
  inspectedAt: json['inspected_at'] != null
      ? DateTime.parse(json['inspected_at'])
      : null,
  reviewedAt: json['reviewed_at'] != null
      ? DateTime.parse(json['reviewed_at'])
      : null,
);

Map<String, dynamic> _$InspectionToJson(Inspection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'customer': instance.customer?.toJson(),
      'vehicle': instance.vehicle?.toJson(),
      'stage': instance.stage.toJson(),
      'created_at': instance.createdDate.toString(),
      'book': instance.center?.toJson(),
      'inspector': instance.inspector?.toJson(),
      'assigned': instance.assignedTo?.toJson(),
      'inspection_type': instance.inspectionType?.toJson(),
      'note': instance.note,
      'rejected_note': instance.rejectedNote,
      'report': instance.report,
      'inspected_at': instance.inspectedAt?.toString(),
      'reviewed_at': instance.reviewedAt?.toString(),
    };
