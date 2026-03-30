import 'package:fahis_inspector/boot/app_service_provider.dart';
import 'package:fahis_inspector/firebase_options.dart';
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
import 'package:sentry_flutter/sentry_flutter.dart';
import 'boot.dart';

part 'helpers.dart';
part 'notifications.dart';

Future<void> _initHive() async {
  await Hive.initFlutter();
  await Hive.openBox('AppSettings');
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Future.wait([
    _initHive(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  if (kReleaseMode) {
    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://4ec6a6367c45345191d2696d165e426e@o4511109901189120.ingest.us.sentry.io/4511109907415040';
        options.sendDefaultPii = true;
      },
      appRunner: () => runApp(SentryWidget(child: const Boot())),
    );
  } else {
    runApp(const Boot());
  }
}
