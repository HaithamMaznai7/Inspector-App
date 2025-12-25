import 'package:fahis_inspector/app/app.dart';
import 'package:fahis_inspector/app/services/app_service.dart';
import 'package:fahis_inspector/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

final NotificationService notificationService = NotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  dd('Initializing Hive...');
  await Hive.initFlutter();
  dd('Initialized Hive...');
  
  await notificationService.initializeServices();

  dd('App Service Initializing...');
  await Get.putAsync<AppService>(
      () async => await AppService().init(),
      permanent: true,
      tag: 'AppService',
  );
  dd('App Service Initializing...');

  runApp(App());
}

void dd($string) {
  if (kDebugMode) {
    print($string);
  }
}
