part of '../order.dart';

Order _$OrderFromJson(Map json) => Order(
  id: json['id'],
  slug: json['slug'],
  status: json['status'],
  businessType: json['business_type'],
  customer: Customer.fromJson(json['customer']),
  items: (json['items'] as List)
      .map((item) => OrderItem.fromJson(item))
      .toList(),
  meta: OrderMeta.fromJson(json['meta']),
  updatedAt: DateTime.parse(json['updated_at']),
  createdAt: DateTime.parse(json['created_at']),
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
  stage: json['stage'],
  vehicle: Vehicle.fromJson(json['vehicle']),
  enable: json['enable'],
  report: json['report'],
  updatedAt: DateTime.parse(json['updated_at']),
  createdAt: DateTime.parse(json['created_at']),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'stage': instance.stage,
  'vehicle': instance.vehicle.toJson(),
  'enable': instance.enable,
  'report': instance.report,
  'updated_at': instance.updatedAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

OrderMeta _$OrderMetaFromJson(Map json) => OrderMeta(
  total: json['total'],
  finishedCount: json['finished_count'],
  processedCount: json['processed_count'],
  rejectedCount: json['rejected_count'],
);

Map<String, dynamic> _$OrderMetaToJson(OrderMeta instance) => <String, dynamic>{
  'total': instance.total,
  'finished_count': instance.finishedCount,
  'processed_count': instance.processedCount,
  'rejected_count': instance.rejectedCount,
};
