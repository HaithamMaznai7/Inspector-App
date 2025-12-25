import 'package:flutter/material.dart';

class MenuItem {
  int id;
  String title;
  IconData? icon;
  Color? color;
  
  MenuItem({required this.id, required this.title, this.icon, this.color});

  tojson() => {
    'id': id,
    'title': title,
  };

  tojsonAsIdAndName() => {
    'id': id,
    'name': title,
  };

  static MenuItem? setAsIdAndName(Map? value){
    if (value == null) return null;
    
    final id = value['id'] as int?;
    final name = value['name']?.toString();
    
    if (id == null || id == 0 || name == null || name.isEmpty) return null;

    return MenuItem(id: id, title: name);
  }

  static MenuItem? set(Map? value){
    if (value == null) return null;
    
    final id = value['id'] as int?;
    final name = value['title']?.toString();

    if (id == null || id == 0 || name == null || name.isEmpty) return null;

    return MenuItem(id: id, title: name);
  }

  @override
  String toString() {
    return title;
  }

  operator == (Object other) =>
      identical(this, other) ||
          other is MenuItem && runtimeType == other.runtimeType && id == other.id;
}
