import 'package:fahis_inspector/features/inspections/models/inspection.dart';

class InspectionCollection {
  String groupSlug;
  num count;
  Customer? customer;
  InspectionCenter? center;

  List<Inspection> inspections;

  InspectionCollection({
    required this.groupSlug,
    required this.count,
    this.customer,
    this.center,
    required this.inspections,
  });

  static InspectionCollection fromApi(Map map) {
    Customer? customer = map['owner'] != null
        ? Customer.set(map['owner'])
        : null;
    InspectionCenter? center = map['center'] != null
        ? InspectionCenter.fromApi(map['center'])
        : null;
    return InspectionCollection(
      groupSlug: map['group_code'],
      count: map['orders_count'],
      customer: customer,
      center: center,
      inspections: Inspection.setList(map['inspections']),
    );
  }

  static List<InspectionCollection> listFromApi(List inspections) {
    List<InspectionCollection> collections = [];

    for (var inspection in inspections) {
      collections.add(InspectionCollection.fromApi(inspection));
    }

    return collections;
  }
}
