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

    // 1. Register SMS listener BEFORE the API call
    OTPDialog.startSmsListener();

    // 2. Fire send-OTP API (don't await — let it run in background)
    final sendFuture = auth().forgetPassword(mobile);

    // 3. Navigate to OTP screen IMMEDIATELY so it's visible when SMS arrives
    final result = await Get.to(() => OTPDialog(
      phoneNumber: mobile,
      sendOtpFuture: sendFuture,
     
    ));

    // User dismissed the screen
    if (result == null) return;

    final code = result['code'] as String;
    final verifyToken = result['token'] as String?;

    if (verifyToken == null) return;

    // 4. Verify OTP
    toggleSignIn();
    String? token;
    try {
      token = await auth().verifyOTP(verifyToken, code);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd(e.toString());
    } finally {
      toggleSignIn();
    }

    if (token == null) return;

    // 5. OTP verified — log the user in
    await auth().loginAfterOTP(token);
  }

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}
