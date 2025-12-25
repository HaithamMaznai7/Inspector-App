import 'package:fahis_inspector/features/authentication/screens/reset_password.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/util/formatters/formatter.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  /// Global Keys
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Controllers
  TextEditingController mobileController = TextEditingController();

  final mobileError = RxnString();

  /// Variables
  var mobile = '';

  /// Flags
  RxBool isSignIn = false.obs;

  toggleSignIn() => isSignIn.toggle();

  void checkLogin() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    formKey.currentState!.save();

    mobile = EFormatter.internationalFormatPhoneNumber(mobileController.text);

    toggleSignIn();
    try {
      await Auth.loginByMobile(mobile);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      print(e.toString());
    } finally {
      toggleSignIn();
    }
  }

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}
