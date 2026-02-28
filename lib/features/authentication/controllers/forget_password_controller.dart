import 'package:fahis_inspector/common/widgets/auth/otp_dialog.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  /// Global Keys
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Controllers
  TextEditingController mobileController = TextEditingController();

  final mobileError = RxnString();

  /// Variables
  var mobile = '';

  /// Flags
  RxBool isSignIn = false.obs;

  void toggleSignIn() => isSignIn.toggle();

  void checkLogin() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    formKey.currentState!.save();

    mobile = mobileController.text.trim();

    toggleSignIn();
    String? verifyToken;
    try {
      verifyToken = await auth().forgetPassword(mobile);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd(e.toString());
    } finally {
      toggleSignIn();
    }

    // Don't proceed if forgetPassword() failed
    if (verifyToken == null) return;

    String? token;
    do {
      final result = await Get.dialog(OTPDialog());

      // User dismissed the dialog — abort without touching loading state
      if (result == null) return;

      toggleSignIn();
      try {
        final code = result['code'];
        token = await auth().verifyOTP(verifyToken, code);
      } on FNetworkException catch (e) {
        e.notify();
      } catch (e) {
        dd(e.toString());
      } finally {
        toggleSignIn();
      }
    } while (token == null);

    Get.toNamed(RoutingUrl.resetPassword, parameters: {'token': token});
  }

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}
