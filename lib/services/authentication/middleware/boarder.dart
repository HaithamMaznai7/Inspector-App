import 'package:fahis_inspector/app/services/app_service.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class BoarderMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    
    if (route != RoutingUrl.onBoarding &&
        !(AppService.getBox?.get('IS_BOARDER') ?? false)) {
      return const RouteSettings(name: RoutingUrl.onBoarding);
    }

    if (route == RoutingUrl.onBoarding &&
        (AppService.getBox?.get('IS_BOARDER') ?? false)) {
      return const RouteSettings(name: RoutingUrl.login);
    }

    return null;
  }
}
