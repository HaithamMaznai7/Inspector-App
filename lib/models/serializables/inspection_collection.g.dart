part of '../inspection_collection.dart';

InspectionCollection _$InspectionCollectionFromJson(Map<String, dynamic> json) {
  Customer? customer = json['owner'] != null
      ? Customer.fromJson(json['owner'])
      : null;
  CenterBranch? center = json['center'] != null
      ? CenterBranch.fromJson(json['center'])
      : null;

  return InspectionCollection(
    groupSlug: json['group_code'],
    count: json['orders_count'],
    customer: customer,
    center: center,
    inspections: Inspection.setList(json['inspections']),
  );
}

Map<String, dynamic> _$InspectionCollectionToJson(
  InspectionCollection instance,
) => <String, dynamic>{
  'group_code': instance.groupSlug,
  'orders_count': instance.count,
  'owner': instance.customer?.toJson() ?? {},
  'center': instance.center?.toJson() ?? {},
  'inspections': instance.inspections.map((element) => element.toJson()).toList(),
};
