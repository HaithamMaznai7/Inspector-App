import 'dart:io';
import 'package:fahis_inspector/main.dart';

import 'selection.dart';
import 'package:flutter/foundation.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/app_config.g.dart';

@JsonSerializable()
class AppConfig {
  String appUrl, baseApiUrl, websiteUrl;
  bool canWorkOffline, maintenanceMode;
  double lastVersion, minSuportVersion;
  List<Selection> fuelTypes,
      bodyNoteTypes,
      drivetrainTypes,
      bodyTypes,
      gasolineTypes,
      gearboxTypes,
      cylinderNumbers,
      seatNumbers,
      seatTypes;

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

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);

  Future<void> save(Box box) async {
    await box.put('CONFIGS', toJson());
  }

  static Future<AppConfig?> read(Box box, {String? fcmToken}) async {
    AppConfig? instance;
    var data = box.get('CONFIGS');
    if (data != null) {
      instance = AppConfig.fromJson(data);
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
      
      if (fcmToken != null) {
        net.setBody = {'fcmToken': fcmToken};
      }

      final response = await net.response(RoutingUrl.login);
      var data = response.data;
      configs = AppConfig.fromJson(data);
      // await configs.save(box);
    } catch (e) {
      dd(e);
      dd(e.toString());
    }
    return configs;
  }
}
