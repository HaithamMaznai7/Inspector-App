import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  TextEditingController credentialController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final credentialError = RxnString();
  final passwordError = RxnString();

  var credential = '';
  var password = '';

  RxBool isLoading = false.obs;
  RxBool isPasswordHidden = true.obs;

  void passwordVisibleChange() => isPasswordHidden.toggle();

  void forgetPassword() => Get.offAllNamed(RoutingUrl.forgetPassword);

  Future<void> checkLogin() async {
    credential = credentialController.text.trim();
    if (!loginFormKey.currentState!.validate()) return;
    loginFormKey.currentState!.save();
    await login();
  }

  Future<void> login() async {
    isLoading.value = true;
    password = passwordController.text;
    credentialError.value = null;
    passwordError.value = null;

    try {
      await auth().login(credential, password);
    } on FNetworkException catch (e) {
      if (e.isCancelled) return;
      if (e.statusCode == 422 && e.errors != null) {
        credentialError.value =
            (e.errors!['email'] as List?)?.firstOrNull?.toString() ??
            (e.errors!['mobile'] as List?)?.firstOrNull?.toString();
        passwordError.value =
            (e.errors!['password'] as List?)?.firstOrNull?.toString();
      } else {
        final msg = e.message.isNotEmpty
            ? e.message
            : 'Something went wrong. Please try again.'.tr;
        FLoader.errorSnackBar(message: msg);
      }
    } on FirebaseAuthException catch (e) {
      dd(e);
    } catch (e) {
      dd(e.toString());
      FLoader.errorSnackBar(
        message: 'Something went wrong. Please try again.'.tr,
        duration: 5,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    credentialController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
