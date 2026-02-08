import 'package:json_annotation/json_annotation.dart';
import 'center_branch.dart';
import 'customer.dart';
import 'inspection.dart';

part 'serializables/inspection_collection.g.dart';

@JsonSerializable()
class InspectionCollection {
  String groupSlug;
  num count;
  Customer? customer;
  CenterBranch? center;
  List<Inspection> inspections;

  InspectionCollection({
    required this.groupSlug,
    required this.count,
    this.customer,
    this.center,
    required this.inspections,
  });

  factory InspectionCollection.fromJson(Map<String, dynamic> json) => _$InspectionCollectionFromJson(json);

  Map<String,dynamic> toJson() => _$InspectionCollectionToJson(this);

  static List<InspectionCollection> listFromApi(List inspections) {
    List<InspectionCollection> collections = [];

    for (var inspection in inspections) {
      collections.add(InspectionCollection.fromJson(inspection));
    }

    return collections;
  }
}