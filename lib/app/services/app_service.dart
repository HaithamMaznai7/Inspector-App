import 'package:fahis_inspector/features/configuration/models/app_config.dart';
import 'package:fahis_inspector/features/configuration/models/selection_model.dart';
import 'package:fahis_inspector/features/notifications/controller/controller.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/services/authentication/repository/auth_repository.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppService extends GetxService with WidgetsBindingObserver {
  static AppService? get instance => Get.find<AppService>(tag: 'AppService');

  late Auth _auth;
  late final ConnectionService _connection;
  NotificationsController? _notification;
  late final Box _box;
  late final Box _configBox;
  Box? get getConfigBox => _configBox;
  String? fcmToken;
  AppConfig? configs;

  static ConnectionService? get connection => instance?._connection;
  static Auth? get auth => instance?._auth;
  static Box? get getBox => instance?._box;

  static List<Selection> get fuelTypes => instance?.configs?.fuelTypes ?? [];
  static List<Selection> get drivetrainTypes =>
      instance?.configs?.drivetrainTypes ?? [];
  static List<Selection> get bodyTypes => instance?.configs?.bodyTypes ?? [];
  static List<Selection> get bodyNoteTypes =>
      instance?.configs?.bodyNoteTypes ?? [];
  static List<Selection> get gearboxTypes =>
      instance?.configs?.gearboxTypes ?? [];
  static List<Selection> get gasolineTypes =>
      instance?.configs?.gasolineTypes ?? [];
  static List<Selection> get cylinderNumbers =>
      instance?.configs?.cylinderNumbers ?? [];
  static List<Selection> get seatNumbers =>
      instance?.configs?.seatNumbers ?? [];
  static List<Selection> get seatTypes => instance?.configs?.seatTypes ?? [];

  Future<AppService> init() async {
    try {
      _box = await Hive.openBox(AuthRepository.authBox);
      fcmToken = _box.get('fcmToken');
      if (fcmToken == null) {
        fcmToken = await FirebaseMessaging.instance.getToken();
        fcmToken = 'q0ppjj2j99aqpjbe0wra';
        print('fcmToken from box: $fcmToken');
        await _box.put('fcmToken', fcmToken);
      }

      _configBox = await Hive.openBox('CONFIG_BOX');

      _connection = Get.put<ConnectionService>(
        ConnectionService(),
        permanent: true,
        tag: 'ConnectionService',
      );

      _auth = await Get.putAsync(
        () async => await Auth().init(),
        permanent: true,
        tag: 'Auth',
      );

      _auth.isAuthenticated.listen((data) async {
        if (data) {
          configs = await AppConfig.read(_configBox, fcmToken: fcmToken);
          Get.offAllNamed(RoutingUrl.home);
        } else {
          configs = await AppConfig.read(_configBox);
          Get.offAllNamed(RoutingUrl.login);
        }
      });

      print('_auth.isAuthenticated.value: ${_auth.isAuthenticated.value}');
      configs = await AppConfig.read(
        _configBox,
        fcmToken: _auth.isAuthenticated.value ? fcmToken : null,
      );
      print(configs);
    } catch (e) {
      if (kDebugMode) {
        print('has an error while initilizing Services');
        print(e.toString());
      }
    } finally {
      WidgetsBinding.instance.addObserver(this);
    }

    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.hidden:
        onHidden();
        break;
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
    }
  }

  onInactive() {
    print('onInactive');
  }

  onDetached() {
    print('onDetached');
  }

  onHidden() {
    print('onHidden');
  }

  onResumed() {
    print('onResumed');
  }

  onPaused() {
    print('onPaused');
  }
}
