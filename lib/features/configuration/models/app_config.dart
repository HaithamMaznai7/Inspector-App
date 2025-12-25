import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fahis_inspector/app/services/app_service.dart';
import 'package:fahis_inspector/features/configuration/models/selection_model.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

class AppConfig {
  String appUrl;
  String baseApiUrl;
  bool canWorkOffline;
  bool maintenanceMode;
  double lastVersion;
  double minSuportVersion;
  String websiteUrl;
  List<Selection> fuelTypes;
  List<Selection> bodyNoteTypes;
  List<Selection> drivetrainTypes;
  List<Selection> bodyTypes;
  List<Selection> gasolineTypes;
  List<Selection> gearboxTypes;
  List<Selection> cylinderNumbers;
  List<Selection> seatNumbers;
  List<Selection> seatTypes;

  AppConfig({
    this.appUrl = EndPoints.baseUrl,
    this.baseApiUrl = EndPoints.baseUrl,
    this.canWorkOffline = false,
    this.maintenanceMode = false,
    this.lastVersion = 1.0,
    this.minSuportVersion = 1.0,
    this.websiteUrl = EndPoints.websiteUrl,
    this.fuelTypes = const [],
    this.bodyNoteTypes = const [],
    this.drivetrainTypes = const [],
    this.bodyTypes = const [],
    this.gasolineTypes = const [],
    this.gearboxTypes = const [],
    this.cylinderNumbers = const [],
    this.seatNumbers = const [],
    this.seatTypes = const [],
  });

  factory AppConfig.set(var map) {
    String appUrl = map['website_url'];
    if (!kIsWeb && Platform.isIOS) {
      appUrl = map['app_store_url'];
    } else if (!kIsWeb && Platform.isAndroid) {
      appUrl = map['app_google_play_url'];
    } else {
      appUrl = map['website_url'];
    }

    AppConfig appConfig = AppConfig(
      appUrl: appUrl,
      baseApiUrl: map['base_api_url'],
      canWorkOffline: map['can_work_offline'],
      maintenanceMode: map['maintenance_mode'],

      // lastVersion: map['last_v'].runtimeType == double
      //     ? map['last_v']
      //     : (map['last_v'] as int).toDouble(),
      lastVersion: 1.0,
      minSuportVersion: 1.0,
      // minSuportVersion: map['min_suport_v'].runtimeType == double
      //     ? map['min_suport_v']
      //     : (map['min_suport_v'] as int).toDouble(),
      websiteUrl: map['website_url'],
      fuelTypes: Selection.setList(map['fuel_types']),
      bodyNoteTypes: Selection.setList(map['body_note_types']),
      drivetrainTypes: Selection.setList(map['drivetrain_types']),
      bodyTypes: Selection.setList(map['body_types']),
      gasolineTypes: Selection.setList(map['gasoline_types']),
      gearboxTypes: Selection.setList(map['gearbox_types']),
      cylinderNumbers: Selection.setList(map['cylinder_numbers']),
      seatNumbers: Selection.setList(map['seat_numbers']),
      seatTypes: Selection.setList(map['seat_types']),
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

  Map<String, dynamic> toJson() {
    return {
      'website_url': websiteUrl,
      'app_store_url': appUrl,
      'app_google_play_url': appUrl,
      'base_api_url': baseApiUrl,
      'can_work_offline': canWorkOffline,
      'maintenance_mode': maintenanceMode,
      'last_v': lastVersion,
      'min_suport_v': minSuportVersion,
      'fuel_types': fuelTypes.map((element) => element.toJson()).toList(),
      'body_note_types': bodyNoteTypes
          .map((element) => element.toJson())
          .toList(),
      'drivetrain_types': drivetrainTypes
          .map((element) => element.toJson())
          .toList(),
      'body_types': bodyTypes.map((element) => element.toJson()).toList(),
      'gasoline_types': gasolineTypes
          .map((element) => element.toJson())
          .toList(),
      'gearbox_types': gearboxTypes.map((element) => element.toJson()).toList(),
      'cylinder_numbers': cylinderNumbers
          .map((element) => element.toJson())
          .toList(),
      'seat_numbers': seatNumbers.map((element) => element.toJson()).toList(),
      'seat_types': seatTypes.map((element) => element.toJson()).toList(),
    };
  }

  Future<void> save(Box box) async {
    await box.put('CONFIGS', toJson());
  }

  static Future<AppConfig?> read(Box box, {String? fcmToken}) async {
    AppConfig? instance;
    var data = box.get('CONFIGS');
    if (data != null) {
      instance = AppConfig.set(data);
    }

    try {
      instance = await AppConfig.fetch(box, fcmToken: fcmToken);
    } catch (_) {}

    return instance;
  }

  static Future<AppConfig?> fetch(Box box, {String? fcmToken}) async {
    AppConfig? configs;
    try {
      Network net = Network(
        endpoint: EndPoints.config,
        requestMethod: RequestMethod.post,
      );

      net.setHeader = {
        'Accept-Language': 'ar'
      };

      if (fcmToken != null) {
        net.setBody = {'fcmToken': fcmToken};
      }

      final response = await net.response(RoutingUrl.login);
      var data = response.data;
      configs = AppConfig.set(data);
      // await configs.save(box);
    } catch (e) {
      print(e);
      print(e.toString());
    }
    return configs;
  }
}
