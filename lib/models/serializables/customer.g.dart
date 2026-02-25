part of '../customer.dart';

Customer _$CustomerFromJson(Map json) => Customer(
  name: json['name'] ?? '',
  email: json['email'],
  phone: json['mobile'],
  city: json['city'] != null ? PlaceHolderModel.fromJson(json['city']) : null,
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'mobile': instance.phone,
  'city': instance.city?.toJson(),
};
