
import 'package:json_annotation/json_annotation.dart';

part 'serializables/city.g.dart';

@JsonSerializable()
class City {

  int id;
  String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  Map<String,dynamic> toJson() => _$CityToJson(this);

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
