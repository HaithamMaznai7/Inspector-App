import 'package:fahis_inspector/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final binding = AuthBinding();

    // If AuthService isn't registered yet, no session is possible.
    if (!binding.isRegistered) {
      if (kDebugMode) {
        debugPrint('[AuthMiddleware] AuthService not registered – redirecting to login');
      }
      return const RouteSettings(name: RoutingUrl.login);
    }

    final auth = binding.instance;

    if (!auth.isAuth) {
      if (kDebugMode) {
        debugPrint('[AuthMiddleware] No valid session – clearing data & redirecting to login');
      }
      // Fire-and-forget: clear stale local data so the next login
      // starts fresh. clearLocalData is safe to call concurrently.
      auth.clearLocalData();
      return const RouteSettings(name: RoutingUrl.login);
    }

    return null;
  }
}
