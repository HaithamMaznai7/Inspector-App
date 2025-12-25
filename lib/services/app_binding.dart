import 'package:fahis_inspector/features/authentication/controllers/login_controller.dart';
import 'package:fahis_inspector/features/authentication/controllers/forget_password_controller.dart';
import 'package:fahis_inspector/features/inspection_body_notes/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_details/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_obd/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_paint_body/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_photos/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_points/controllers/controller.dart';
import 'package:fahis_inspector/features/inspections/controllers/home_controller.dart';
import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
import 'package:fahis_inspector/features/notifications/controller/controller.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:get/get.dart';

class OfflineBinding implements Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    //Get.lazyPut(() => NetworkController(),fenix: true);
  }
}

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => LoginController());
  }
}

class RestorePasswordBinding implements Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => ForgetPasswordController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NotificationsController>(
      NotificationsController(),
      permanent: true,
      tag: 'NotificationService',
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true,
    ); // ensure it's recreated if disposed
  }
}

class InspectionBinding implements Bindings {
  @override
  void dependencies() {
    final slug = Get.parameters['slug'];

    if (slug == null) {
      Get.offAllNamed(RoutingUrl.home);
      return;
    }

    final tag = 'inspection';

    if (Get.isRegistered<InspectionController>(tag: tag)) {
      Get.delete<InspectionController>(tag: tag);
    }

    Get.put<InspectionController>(InspectionController(slug), tag: tag);
  }
}
