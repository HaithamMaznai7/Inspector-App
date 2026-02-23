import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/team.dart';
import 'package:fahis_inspector/resources/profile_repository.dart';
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
    if (team.id == null) return;
    try {
      final updatedProfile = await ProfileRepository().switchTeam(team.id!);
      auth().profile = updatedProfile;
      Get.offAllNamed(RoutingUrl.home);
    } catch (e) {
      dd('Error switching team: $e');
    }
  }
}
