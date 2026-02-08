import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/menu_item.g.dart';

@JsonSerializable()
class MenuItem {
  int id;
  String title;
  IconData? icon;
  Color? color;

  MenuItem({required this.id, required this.title, this.icon, this.color});

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  factory MenuItem.fromJsonAsIdAndName(Map<String, dynamic> json) =>
      _$MenuItemFromJsonAsIdAndName(json);

  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
  
  Map<String, dynamic> toJsonAsIdAndName() => _$MenuItemToJsonAsIdAndName(this);
}
