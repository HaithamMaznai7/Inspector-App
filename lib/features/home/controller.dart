import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/team.dart';
import 'package:fahis_inspector/resources/profile_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {

  final sideController = SideMenuController();

  @override
  void onReady() {
    super.onReady();
    // InspectionsController is created by GetBuilder(init:) in the view.
    // No need to call InspectionsBinding().dependencies() here — doing so
    // would delete the controller the view is already using and cause a
    // "ScrollController used after being disposed" error.
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
