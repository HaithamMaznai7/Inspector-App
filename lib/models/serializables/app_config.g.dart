part of '../app_config.dart';

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
    String appUrl = json['website_url'];
  if (!kIsWeb && Platform.isIOS) {
    appUrl = json['app_store_url'];
  } else if (!kIsWeb && Platform.isAndroid) {
    appUrl = json['app_google_play_url'];
  } else {
    appUrl = json['website_url'];
  }

  AppConfig appConfig = AppConfig(
    appUrl: appUrl,
    baseApiUrl: json['base_api_url'],
    canWorkOffline: json['can_work_offline'],
    maintenanceMode: json['maintenance_mode'],

    // lastVersion: json['last_v'].runtimeType == double
    //     ? json['last_v']
    //     : (json['last_v'] as int).toDouble(),
    lastVersion: 1.0,
    minSuportVersion: 1.0,
    // minSuportVersion: json['min_suport_v'].runtimeType == double
    //     ? json['min_suport_v']
    //     : (json['min_suport_v'] as int).toDouble(),
    websiteUrl: json['website_url'],
    fuelTypes: Selection.setList(json['fuel_types']),
    bodyNoteTypes: Selection.setList(json['body_note_types']),
    drivetrainTypes: Selection.setList(json['drivetrain_types']),
    bodyTypes: Selection.setList(json['body_types']),
    gasolineTypes: Selection.setList(json['gasoline_types']),
    gearboxTypes: Selection.setList(json['gearbox_types']),
    cylinderNumbers: Selection.setList(json['cylinder_numbers']),
    seatNumbers: Selection.setList(json['seat_numbers']),
    seatTypes: Selection.setList(json['seat_types']),
  );

  if (appConfig.bodyTypes.where((element) => element.value == '0').isEmpty) {
    appConfig.bodyTypes.insert(0, Selection(value: '0', label: 'none'));
  }
  if (appConfig.fuelTypes.where((element) => element.value == '0').isEmpty) {
    appConfig.fuelTypes.insert(0, Selection(value: '0', label: 'none'));
  }
  if (appConfig.drivetrainTypes
      .where((element) => element.value == '0')
      .isEmpty) {
    appConfig.drivetrainTypes.insert(0, Selection(value: '0', label: 'none'));
  }

  return appConfig;
}

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
  'website_url': instance.websiteUrl,
  'app_store_url': instance.appUrl,
  'app_google_play_url': instance.appUrl,
  'base_api_url': instance.baseApiUrl,
  'can_work_offline': instance.canWorkOffline,
  'maintenance_mode': instance.maintenanceMode,
  'last_v': instance.lastVersion,
  'min_suport_v': instance.minSuportVersion,
  'fuel_types': instance.fuelTypes.map((element) => element.toJson()).toList(),
  'body_note_types': instance.bodyNoteTypes
      .map((element) => element.toJson())
      .toList(),
  'drivetrain_types': instance.drivetrainTypes
      .map((element) => element.toJson())
      .toList(),
  'body_types': instance.bodyTypes.map((element) => element.toJson()).toList(),
  'gasoline_types': instance.gasolineTypes
      .map((element) => element.toJson())
      .toList(),
  'gearbox_types': instance.gearboxTypes.map((element) => element.toJson()).toList(),
  'cylinder_numbers': instance.cylinderNumbers
      .map((element) => element.toJson())
      .toList(),
  'seat_numbers': instance.seatNumbers.map((element) => element.toJson()).toList(),
  'seat_types': instance.seatTypes.map((element) => element.toJson()).toList(),
};