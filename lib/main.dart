import 'package:fahis_inspector/boot/app_service_provider.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/auth/auth_service.dart';
import 'package:fahis_inspector/services/notifications/notifications_service.dart';
import 'package:fahis_inspector/services/storage/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boot.dart';

part 'helpers.dart';
part 'notifications.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();
  runApp(const Boot());
}
