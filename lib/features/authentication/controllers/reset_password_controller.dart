import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController =
      TextEditingController();

  late final String resetToken;

  final RxBool isLoading = false.obs;
  final RxBool showPassword = false.obs;
  final RxBool showPasswordConfirmation = false.obs;

  @override
  void onInit() {
    super.onInit();
    resetToken = Get.parameters['token'] ?? '';
  }

  void resetPassword() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    isLoading.value = true;
    try {
      await auth().resetPassword(
        resetToken,
        passwordConfirmationController.text.trim(),
        passwordController.text.trim(),
      );
      Get.offAllNamed(RoutingUrl.login);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.onClose();
  }
}
