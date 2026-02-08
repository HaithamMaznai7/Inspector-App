import 'package:fahis_inspector/firebase_options.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/app/app_service.dart';
import 'package:fahis_inspector/services/app/support/bindings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class AppServiceProvider extends AppService {
  @override
  Future<void> boot() async {
    super.boot();

    try {
      // await Hive.initFlutter();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      }
    } catch (_) {
      dd('error on boot method');
    }
    // dd('End Initialize Firebase');
  }

  @override
  List<BindingsService> register() {
    return [
      StorageBinding(),
      AuthBinding(),
      NotificationsBinding(),
    ];
  }
}
