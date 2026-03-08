part of '../order.dart';

Order _$OrderFromJson(Map json) => Order(
  id: json['id'],
  slug: json['slug'] ?? '',
  status: json['status'] ?? '',
  businessType: json['business_type'] ?? '',
  customer: Customer.fromJson(json['customer'] ?? {}),
  items: json['items'] != null
      ? (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList()
      : [],
  meta: OrderMeta.fromJson(json['meta'] ?? {}),
  updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
  createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'status': instance.status,
  'business_type': instance.businessType,
  'customer': instance.customer.toJson(),
  'items': instance.items.map((item) => item.toJson()).toList(),
  'meta': instance.meta.toJson(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

OrderItem _$OrderItemFromJson(Map json) => OrderItem(
  id: json['id'],
  slug: json['slug'],
  stage: json['stage'] ?? 'pending',
  vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
  inspectionType: json['inspection_type'] != null
      ? InspectionType.fromJson(json['inspection_type'])
      : null,
  enable: json['enable'] ?? true,
  report: json['report'],
  updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
  createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'stage': instance.stage,
  'vehicle': instance.vehicle.toJson(),
  'inspection_type': instance.inspectionType?.toJson(),
  'enable': instance.enable,
  'report': instance.report,
  'updated_at': instance.updatedAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

OrderMeta _$OrderMetaFromJson(Map json) => OrderMeta(
  total: json['total'] ?? 0,
  finishedCount: json['finished_count'] ?? 0,
  processedCount: json['processed_count'] ?? 0,
  rejectedCount: json['rejected_count'] ?? 0,
);

Map<String, dynamic> _$OrderMetaToJson(OrderMeta instance) => <String, dynamic>{
  'total': instance.total,
  'finished_count': instance.finishedCount,
  'processed_count': instance.processedCount,
  'rejected_count': instance.rejectedCount,
};
