import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/util/formatters/formatter.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  static ResetPasswordController get instance => Get.find();

  /// Global Keys
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Controllers
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController =
      TextEditingController();

  final passwordError = RxnString();
  final passwordConfirmationError = RxnString();

  /// Variables
  var mobile = '';

  /// Flags
  RxBool isResetPassword = false.obs;

  toggleResetPassword() => isResetPassword.toggle();

  void resetPassword() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    formKey.currentState!.save();

    mobile = EFormatter.internationalFormatPhoneNumber(Auth.user!.mobile);

    toggleResetPassword();
    try {
      await Auth.loginByMobile(mobile);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      print(e.toString());
    } finally {
      toggleResetPassword();
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.onClose();
  }
}
