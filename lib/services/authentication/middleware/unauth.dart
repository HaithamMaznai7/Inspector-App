import '../auth.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UnauthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Auth.check) {
      return const RouteSettings(name: RoutingUrl.home);
    }

    return null;
  }
}
