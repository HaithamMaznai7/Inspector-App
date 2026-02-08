part of '../../routes.dart';

class LoginBinding extends BindingsService<LoginController> {

  @override
  final String? tag = BindingTags.login;

  @override
  void dependencies() async {
    if (Get.isRegistered(tag: tag)) {
      final LoginController controller = Get.find<LoginController>(tag: tag);
      controller.onClose();
    }

    Get.put<LoginController>(LoginController(), tag: tag);
  }
}

class ForgetBinding extends BindingsService<ForgetPasswordController> {
  
  @override
  final String? tag = BindingTags.forgetPassword;

  @override
  void dependencies() async {
    if (Get.isRegistered(tag: tag)) {
      final ForgetPasswordController controller =
          Get.find<ForgetPasswordController>(tag: tag);
      controller.onClose();
    }

    Get.put<ForgetPasswordController>(ForgetPasswordController(), tag: tag);
  }
}

class ResetPasswordBinding extends BindingsService<ResetPasswordController> {
  
  @override
  final String? tag = BindingTags.resetPassword;

  @override
  void dependencies() async {
    if (! isRegistered) {
      instance.onClose();
    }

    Get.put<ResetPasswordController>(ResetPasswordController(), tag: tag);
  }
}
