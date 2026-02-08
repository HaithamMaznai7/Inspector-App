part of '../settings.dart';

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
  locale: const Locale('ar', 'SA'),
  theme: ThemeMode.light,
);

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'locale': instance.locale,
  'theme': instance.theme.toString(),
};
