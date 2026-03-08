import 'customer.dart';
import 'vehicle.dart';
import 'inspection_type.dart';

part 'serializables/order.g.dart';

class Order {
  int id;
  String slug;
  String status;
  String businessType;
  Customer customer;
  List<OrderItem> items;
  OrderMeta meta;
  DateTime updatedAt;
  DateTime createdAt;

  Order({
    required this.id,
    required this.slug,
    required this.status,
    required this.businessType,
    required this.customer,
    required this.items,
    required this.meta,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Order.fromJson(Map json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

class OrderItem {
  int id;
  String? slug;
  String stage;
  Vehicle vehicle;
  InspectionType? inspectionType;
  bool enable;
  String? report;
  DateTime updatedAt;
  DateTime createdAt;

  OrderItem({
    required this.id,
    this.slug,
    required this.stage,
    required this.vehicle,
    this.inspectionType,
    required this.enable,
    this.report,
    required this.updatedAt,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map json) => _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

class OrderMeta {
  int total;
  int finishedCount;
  int processedCount;
  int rejectedCount;

  OrderMeta({
    required this.total,
    required this.finishedCount,
    required this.processedCount,
    required this.rejectedCount,
  });

  factory OrderMeta.fromJson(Map json) => _$OrderMetaFromJson(json);

  Map<String, dynamic> toJson() => _$OrderMetaToJson(this);
}
