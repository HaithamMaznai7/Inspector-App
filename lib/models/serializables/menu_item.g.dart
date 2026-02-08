part of '../menu_item.dart';

MenuItem _$MenuItemFromJsonAsIdAndName(Map<String, dynamic> json)
  => MenuItem(id: json['id'] as int, title: json['name'] as String);

MenuItem _$MenuItemFromJson(Map<String, dynamic> json)
  => MenuItem(id: json['id'] as int, title: json['title'] as String);
  
Map<String, dynamic> _$MenuItemToJsonAsIdAndName(MenuItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.title,
};

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
};