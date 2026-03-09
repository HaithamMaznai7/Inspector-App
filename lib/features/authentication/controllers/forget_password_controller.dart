import 'package:fahis_inspector/common/widgets/auth/otp_dialog.dart';
import 'package:fahis_inspector/main.dart';
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

      // Resend action — re-request OTP and loop back to show dialog again
      if (result['action'] == 'resent') {
        toggleSignIn();
        try {
          verifyToken = await auth().forgetPassword(mobile);
        } on FNetworkException catch (e) {
          e.notify();
        } catch (e) {
          dd(e.toString());
        } finally {
          toggleSignIn();
        }
        if (verifyToken == null) return;
        continue;
      }

      toggleSignIn();
      try {
        final code = result['code'] as String;
        token = await auth().verifyOTP(verifyToken!, code);
      } on FNetworkException catch (e) {
        e.notify();
      } catch (e) {
        dd(e.toString());
      } finally {
        toggleSignIn();
      }
    } while (token == null);

    // OTP verified — token is the session token, log the user in directly
    await auth().loginAfterOTP(token);
  }

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}
