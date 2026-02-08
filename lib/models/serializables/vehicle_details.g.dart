part of '../vehicle_details.dart';

VehicleDetails _$InspectionDetailsFromJson(Map json) => VehicleDetails(
  vin: json['vin'],
  plate: json['plate'],
  bodyType: json['body_type_id'],
  fuelType: json['fuel_type'],
  gasolineType: json['gasoline_type'],
  drivetrain: json['drivetrain'],
  gearbox: json['gearbox_type'],
  milage: json['milage'],
  cylindersNo: json['cylinders_no'],
  seatsNo: json['seats_no'],
  seatsType: json['seats_type'],
  color: json['color'],
  seatColor: json['seats_color'],
  yearModel: json['year_model'],
  enginSize: json['engine_size'],
);

Map<String, dynamic> _$InspectionDetailsToJson(VehicleDetails instance) =>
    <String, dynamic>{
      'vin': instance.vin,
      'plate': instance.plate,
      'body_type_id': instance.bodyType,
      'fuel_type': instance.fuelType,
      'drivetrain': instance.drivetrain,
      'gasoline_type': instance.gasolineType,
      'gearbox_type': instance.gearbox,
      'milage': instance.milage,
      'cylinders_no': instance.cylindersNo,
      'seats_no': instance.seatsNo,
      'seats_type': instance.seatsType,
      'color': instance.color,
      'seats_color': instance.seatColor,
      'year_model': instance.yearModel,
      'engine_size': instance.enginSize,
    };
