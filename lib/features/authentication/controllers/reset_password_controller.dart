import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/util/formatters/formatter.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
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

    mobile = EFormatter.internationalFormatPhoneNumber(
      auth().user!.phoneNumber!,
    );

    toggleResetPassword();
    try {
      await auth().forgetPassword(mobile);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd(e.toString());
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
