import 'package:fahis_inspector/models/team.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {

  final sideController = SideMenuController();

  // @override
  // void onReady() {
  //   super.onReady();

  //   InspectionsBinding().dependencies();
  // }

  @override
  void onReady() {
    super.onReady();

    InspectionsBinding().dependencies();
  }

  void changeTeam(Team team) async {
    // Get.back();
    // try {
    //   await Auth.setTeam(team);
    // } finally {
    //   repository.fetchFromApi();
    //   Get.back();
    // }
  }
}
