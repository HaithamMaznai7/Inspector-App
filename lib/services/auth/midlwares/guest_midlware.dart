import 'package:fahis_inspector/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if(AuthBinding().isRegistered && AuthBinding().instance.isAuth){
      return const RouteSettings(name: RoutingUrl.home);
    }

    return null;
  }
}
