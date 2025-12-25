import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:get/get.dart';
class NavigationService{

  static final NavigationService _instance = NavigationService._internal();

  NavigationService._internal();
  factory NavigationService() => _instance ;


  dynamic getBack([dynamic popValue]) {
    return Get.back(result: popValue);
  }

  Future<dynamic> getTo(String route,{parameters, arguments}) async => Get.toNamed(route) ;

  Future<dynamic> getOff(String route,{parameters, arguments}) async => Get.offNamed(route) ;

  Future<dynamic> getOffAll(String route,{parameters, arguments}) async => Get.offAllNamed(route) ;

  void getToFirst() => Get.offAllNamed(RoutingUrl.login);

}