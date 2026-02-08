import 'placeholder_model.dart';

part 'serializables/customer.g.dart';

class Customer {
  String name;
  String? email;
  String? phone;
  PlaceHolderModel? city;

  Customer({this.name = '', this.email, this.phone, this.city});

  factory Customer.fromJson(Map json) =>
      _$CustomerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}
