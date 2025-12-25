import 'package:fahis_inspector/features/inspections/models/inspection_stages.dart';
import 'package:fahis_inspector/util/constants/enums.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Inspection {
  int id;
  String slug;
  Customer? customer;
  Vehicle? vehicle;
  InspectionCenter? center;
  ModelItem? inspector;
  ModelItem? assignedTo;
  InspectionStage stage;
  UploadStatus uploadStatus = UploadStatus.notDownloaded;
  InspectionType? inspectionType;
  String note;
  String? rejectedNote;
  String? report;
  DateTime? inspectedAt;
  DateTime? reviewedAt;
  DateTime createdDate;

  bool get hasDetails => inspectionType?.hasDetails ?? false;
  bool get hasPoints => inspectionType?.hasPoints ?? false;
  bool get hasPhotos => inspectionType?.hasPhotos ?? false;
  bool get hasBody => inspectionType?.hasBody ?? false;
  bool get hasPaintBody => inspectionType?.hasPaintBody ?? false;
  bool get hasObd => inspectionType?.hasObd ?? false;

  Inspection({
    required this.id,
    required this.slug,
    required this.customer,
    this.vehicle,
    this.center,
    this.inspector,
    this.assignedTo,
    String? stageValue,
    this.inspectionType,
    required this.uploadStatus,
    this.note = '',
    this.rejectedNote,
    this.report,
    this.inspectedAt,
    this.reviewedAt,
    required this.createdDate,
  }) : stage = InspectionStage.fromString(stageValue);

  factory Inspection.set(Map<String, dynamic> map) => Inspection(
    id: map['id'],
    slug: map['slug'],
    customer: Customer.set(map['customer']),
    vehicle: Vehicle.fromApi(map['vehicle']),
    stageValue: map['stage'],
    uploadStatus: UploadStatus.live,
    createdDate: DateTime.parse(map['created_at']),
    center: map['book'] != null && map['book'].runtimeType == Map ? InspectionCenter.fromApi(map['book']) : null,
    inspector: map['inspector'] != null ? ModelItem.fromApi(map['inspector']) : null,
    assignedTo: map['assigned'] != null ? ModelItem.fromApi(map['assigned']) : null,
    inspectionType: map['inspection_type'] != null ? InspectionType.fromApi(map['inspection_type']) : null,
    note: map['note'] ?? '',
    rejectedNote: map['rejected_note'],
    report: map['report'],
    inspectedAt: map['inspected_at'] != null ? DateTime.parse(map['inspected_at']) : null,
    reviewedAt: map['reviewed_at'] != null ? DateTime.parse(map['reviewed_at']) : null,
  );

  static List<Inspection> setList(List inspections) =>
      inspections.map((inspection) => Inspection.set(inspection)).toList();

  Inspection setDetails(Map map) {
    if (map['book'].runtimeType == Map) {
      center = InspectionCenter.fromApi(map['book']);
    }
    inspector = map['inspector'] != null
        ? ModelItem.fromApi(map['inspector'])
        : null;
    assignedTo = map['assigned'] != null
        ? ModelItem.fromApi(map['assigned'])
        : null;
    // status = Selection(value: map['status']['id'], label: map['status']['name']);
    stage = InspectionStage.fromString(map['stage']);
    inspectionType = InspectionType.fromApi(map['inspection_type']);
    note = map['note'] ?? '';
    rejectedNote = map['rejected_note'] ?? null;
    report = map['report'] ?? null;
    inspectedAt = map['inspected_at'] != null
        ? DateTime.parse(map['inspected_at'])
        : null;
    reviewedAt = map['reviewed_at'] != null
        ? DateTime.parse(map['reviewed_at'])
        : null;

    return this;
  }

  // factory Inspection.get(Box box, Inspection inspection) =>
  //     inspe.de(box.get('Inspection-$slug'));

  saveDetails(Box box) {
    box.put('Inspection-$slug', toJson);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'customer': customer?.toJson(),
    'vehicle': vehicle?.toJson(),
    'stage': stage.value,
    'created_at': createdDate.toString(),
    'book': center?.toJson(),
    'inspector': inspector?.toJson(),
    'assigned': assignedTo?.toJson(),
    'inspection_type': inspectionType?.toJson(),
    'note': note,
    'rejected_note': rejectedNote,
    'report': report,
    'inspected_at': inspectedAt?.toString(),
    'reviewed_at': reviewedAt?.toString(),
  };

  @override
  int get hashCode => id.hashCode;
}

class InspectionType {
  int id;
  String title;
  String description;
  bool hasDetails;
  bool hasPoints;
  bool hasPhotos;
  bool hasBody;
  bool hasPaintBody;
  bool hasObd;

  InspectionType({
    required this.id,
    required this.title,
    this.description = '',
    this.hasDetails = false,
    this.hasPoints = false,
    this.hasPhotos = false,
    this.hasBody = false,
    this.hasObd = false,
    this.hasPaintBody = false,
  });

  static InspectionType fromApi(Map map) => InspectionType(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    hasPoints :map['has_points'] == 1,
    hasPhotos :map['has_photos']  == 1,
    hasBody :map['has_body'] == 1,
    hasObd :map['has_obd'] == 1,
    hasDetails :map['has_details'] == 1,
    hasPaintBody :map['has_body_points'] == 1
  );

  toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'has_points': hasPoints,
    'has_photos': hasPhotos,
    'has_body': hasBody,
    'has_obd': hasObd,
    'has_details': hasDetails,
    'has_body_points': hasPaintBody,
  };
}

class InspectionCenter {
  ModelItem center;
  ModelItem? branch;
  ModelItem? city;
  DateTime? datetime;
  String? date;

  InspectionCenter({
    required this.center,
    this.branch,
    this.city,
    this.datetime,
    this.date,
  });

  static InspectionCenter? fromApi(Map? map) => map != null
      ? InspectionCenter(
          center: ModelItem.fromApi(map['center'])!,
          branch: ModelItem.fromApi(map['branch']),
          city: ModelItem.fromApi(map['city']),
          datetime: DateTime.parse(map['date']),
          date: map['datetime'],
        )
      : null;

  toJson() => {
    'center': center.toJson(),
    'branch': branch?.toJson(),
    'city': city?.toJson(),
    'date': datetime?.toString(),
    'datetime': date,
  };
}

class Customer {
  String name;
  String? phone;
  ModelItem? city;

  Customer({required this.name, this.phone, this.city});

  factory Customer.set(Map map) => Customer(
    name: map['name'],
    phone: map['mobile'],
    city: map['city'] != null ? ModelItem.fromApi(map['city']) : null,
  );

  toJson() => {'name': name, 'mobile': phone, 'city': city?.toJson()};
}

class Vehicle {
  ModelItem? make;
  ModelItem? model;
  String? year;
  String? plate;

  Vehicle({this.make, this.model, this.year, this.plate});

  static Vehicle fromApi(Map map) => Vehicle(
    make: map['make'] != null ? ModelItem.fromApi(map['make']) : null,
    model: map['model'] != null ? ModelItem.fromApi(map['model']) : null,
    year: map['year'],
    plate: map['plate'],
  );

  toJson() => {
    'make': make?.toJson(),
    'model': model?.toJson(),
    'year': year,
    'plate': plate,
  };
}

class ModelItem {
  num id;
  String label;
  String? avatar;

  ModelItem({required this.id, required this.label, this.avatar});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return label;
  }

  static ModelItem? fromApi(Map map) => map['id'] != null
      ? ModelItem(id: map['id'], label: map['label'], avatar: map['avatar'])
      : null;

  toJson() => {'id': id, 'label': label, 'avatar': avatar};
}
