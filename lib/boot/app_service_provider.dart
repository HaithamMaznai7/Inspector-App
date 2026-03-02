import 'package:fahis_inspector/firebase_options.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/app/app_service.dart';
import 'package:fahis_inspector/services/app/support/bindings_service.dart';
import 'package:fahis_inspector/services/force_update/force_update_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AppServiceProvider extends AppService {
  /// Whether a force update is required. Set during [boot] and read by
  /// [AppService.init] to decide whether to show the force-update screen
  /// instead of proceeding with normal startup.
  bool requiresForceUpdate = false;

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

      // Check force update after Firebase is ready.
      // On failure the service returns false — user is never blocked.
      requiresForceUpdate = await ForceUpdateService.instance.check();
    } catch (_) {
      dd('error on boot method');
    }
  }

  @override
  List<BindingsService> register() {
    return [StorageBinding(), AuthBinding(), NotificationsBinding()];
  }
}
