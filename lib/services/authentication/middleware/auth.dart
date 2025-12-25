import '../auth.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (! Auth.check) {
      return const RouteSettings(name: RoutingUrl.login);
    }

    // if(Auth.user!.status == AccounStatus.passwordReset){
    //   return const RouteSettings(name: RoutingUrl.login);
    // }

    // if(Auth.user!.status == AccounStatus.inactive){
    //   return const RouteSettings(name: RoutingUrl.login);
    // }
    
    // if(Auth.user!.status == AccounStatus.created){
    //   return const RouteSettings(name: RoutingUrl.login);
    // }

    return null;
  }
}
