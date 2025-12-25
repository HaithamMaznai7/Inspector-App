class InspectionDetails {
  String? vin;
  String? plate;
  String? bodyType;
  String? fuelType;
  String? gasolineType;
  String? drivetrain;
  String? gearbox;
  String? milage;
  String? cylindersNo;
  String? seatsNo;
  String? seatsType;
  String? color;
  String? seatColor;
  String? yearModel;
  String? enginSize;

  InspectionDetails({
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

  static InspectionDetails empty() {
    return InspectionDetails();
  }

  bool isEmpty() {
    return (vin?.isEmpty ?? true) ||
        (plate?.isEmpty ?? true) ||
        (bodyType?.isEmpty ?? true) ||
        (fuelType?.isEmpty ?? true) ||
        (gasolineType?.isEmpty ?? true) ||
        (drivetrain?.isEmpty ?? true) ||
        (gearbox?.isEmpty ?? true) ||
        (milage?.isEmpty ?? true) ||
        (cylindersNo?.isEmpty ?? true) ||
        (seatsNo?.isEmpty ?? true) ||
        (seatsType?.isEmpty ?? true) ||
        (color?.isEmpty ?? true) ||
        (seatColor?.isEmpty ?? true) ||
        (yearModel?.isEmpty ?? true) ||
        (enginSize?.isEmpty ?? true);
  }

  InspectionDetails copyWith({
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
    return InspectionDetails(
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

  factory InspectionDetails.set(var map)
  => InspectionDetails(
    vin: map['vin'],
    plate: map['plate'],
    bodyType: map['body_type_id'],
    fuelType: map['fuel_type'],
    gasolineType: map['gasoline_type'],
    drivetrain: map['drivetrain'],
    gearbox: map['gearbox_type'],
    milage: map['milage'],
    cylindersNo: map['cylinders_no'],
    seatsNo: map['seats_no'],
    seatsType: map['seats_type'],
    color: map['color'],
    seatColor: map['seats_color'],
    yearModel: map['year_model'],
    enginSize: map['engine_size'],
  );

  Map<String, dynamic> toJson() => {
    'vin': vin,
    'plate': plate,
    'body_type_id': bodyType,
    'fuel_type': fuelType,
    'drivetrain': drivetrain,
    'gasoline_type': gasolineType,
    'gearbox_type': gearbox,
    'milage': milage,
    'cylinders_no': cylindersNo,
    'seats_no': seatsNo,
    'seats_type': seatsType,
    'color': color,
    'seats_color': seatColor,
    'year_model': yearModel,
    'engine_size': enginSize,
  };
}
