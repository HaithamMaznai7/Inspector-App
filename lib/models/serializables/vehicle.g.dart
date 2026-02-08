part of '../vehicle.dart';

Vehicle _$VehicleFromJson(Map json) => Vehicle(
  make: json['make'] != null ? PlaceHolderModel.fromJson(json['make']) : null,
  model: json['model'] != null
      ? PlaceHolderModel.fromJson(json['model'])
      : null,
  year: json['year'],
  plate: json['plate'],
);

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
  'make': instance.make?.toJson(),
  'model': instance.model?.toJson(),
  'year': instance.year,
  'plate': instance.plate,
};
