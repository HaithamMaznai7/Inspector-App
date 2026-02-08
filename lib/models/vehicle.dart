import 'placeholder_model.dart';

part 'serializables/vehicle.g.dart';

class Vehicle {
  PlaceHolderModel? make;
  PlaceHolderModel? model;
  String? vin;
  String? serialNo;
  String? year;
  String? plate;
  String? price;
  String? storageSize;
  String? vehicleShape;

  Vehicle({this.make, this.model, this.year, this.plate});

  factory Vehicle.fromJson(Map json) =>
      _$VehicleFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}
