
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/settings.g.dart';

@JsonSerializable()
class Settings {
  Locale locale;
  ThemeMode theme;

  Settings({
    this.locale = const Locale('ar', 'SA'),
    this.theme = ThemeMode.light
  });

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
