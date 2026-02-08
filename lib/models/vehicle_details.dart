import 'package:json_annotation/json_annotation.dart';

part 'serializables/vehicle_details.g.dart';

@JsonSerializable()
class VehicleDetails {
  String? vin,
      plate,
      bodyType,
      fuelType,
      gasolineType,
      drivetrain,
      gearbox,
      milage,
      cylindersNo,
      seatsNo,
      seatsType,
      color,
      seatColor,
      yearModel,
      enginSize;

  VehicleDetails({
    this.vin,
    this.plate,
    this.bodyType,
    this.fuelType,
    this.gasolineType,
    this.drivetrain,
    this.gearbox,
    this.milage,
    this.cylindersNo,
    this.seatsNo,
    this.seatsType,
    this.color,
    this.seatColor,
    this.yearModel,
    this.enginSize,
  });

  // Serialization
  factory VehicleDetails.fromJson(Map json) =>
      _$InspectionDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$InspectionDetailsToJson(this);

  static VehicleDetails empty() {
    return VehicleDetails();
  }

  VehicleDetails copyWith({
    String? vin,
    String? plate,
    String? bodyType,
    String? fuelType,
    String? gasolineType,
    String? drivetrain,
    String? gearbox,
    String? milage,
    String? cylindersNo,
    String? seatsNo,
    String? seatsType,
    String? color,
    String? seatColor,
    String? yearModel,
    String? enginSize,
  }) {
    return VehicleDetails(
      vin: vin ?? this.vin,
      plate: plate ?? this.plate,
      bodyType: bodyType ?? this.bodyType,
      fuelType: fuelType ?? this.fuelType,
      gasolineType: gasolineType ?? this.gasolineType,
      drivetrain: drivetrain ?? this.drivetrain,
      gearbox: gearbox ?? this.gearbox,
      milage: milage ?? this.milage,
      cylindersNo: cylindersNo ?? this.cylindersNo,
      seatsNo: seatsNo ?? this.seatsNo,
      seatsType: seatsType ?? this.seatsType,
      color: color ?? this.color,
      seatColor: seatColor ?? this.seatColor,
      yearModel: yearModel ?? this.yearModel,
      enginSize: enginSize ?? this.enginSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleDetails &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;

  @override
  int get hashCode =>
      vin.hashCode ^
      plate.hashCode ^
      bodyType.hashCode ^
      fuelType.hashCode ^
      gasolineType.hashCode ^
      drivetrain.hashCode ^
      gearbox.hashCode ^
      milage.hashCode ^
      cylindersNo.hashCode ^
      seatsNo.hashCode ^
      seatsType.hashCode ^
      color.hashCode ^
      seatColor.hashCode ^
      yearModel.hashCode ^
      enginSize.hashCode;

  bool isEmpty() => VehicleDetails.empty() == this;
}
