import 'package:fahis_inspector/app/services/app_service.dart';
import 'package:fahis_inspector/common/widget/loaders/loaders.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  /// Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final emailError = RxnString();
  final passwordError = RxnString();

  /// Variables
  var email = '';
  var password = '';
  String phoneNO = '';

  /// Flags
  RxBool isLoading = false.obs;
  RxBool rememberMe = true.obs;
  RxBool isPasswordHidden = true.obs;

  void toggleLoading() => isLoading.toggle();
  void toggleRememberMe() => rememberMe.toggle();
  void passwordVisibleChange() => isPasswordHidden.toggle();

  void forgetPassword() => Get.offAllNamed(RoutingUrl.forgetPassword);

  Future<void> checkLogin() async {
    final isValid = loginFormKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    loginFormKey.currentState!.save();

    await login();
  }

  Future<void> login() async {
    toggleLoading();
    email = emailController.text.trim();
    password = passwordController.text;
    emailError.value = null;
    passwordError.value = null;

    try {
      if(Auth.auth == null){
        await Get.putAsync<AppService>(
          () async => await AppService().init(),
          permanent: true,
          tag: 'AppService',
        );
      }
      await Auth.login(email, password);
    } on FNetworkException catch (e) {
      if (e.statusCode == 422 && e.errors != null) {
        final errors = e.errors!;
        if (errors['credential'] != null &&
            errors['credential'].runtimeType == List) {
          emailError.value = errors['credential'].first;
        }
        if (errors['password'] != null &&
            errors['password'].runtimeType == List) {
          passwordError.value = errors['password'].first;
        }
      } else {
        e.notify();
      }
      // } catch (e) {
      // print(e);
      // FLoader.errorSnackBar(
      //   title: 'Unexpected error'.tr,
      //   message:
      //       'We are Sorry, There an error that need to handle by technocal team connect with our support team to solve this issue',
      //   duration: 10,
      // );
    } finally {
      toggleLoading();
    }
  }

  @override
  void onClose() {
    emailController.dispose();

    passwordController.dispose();

    super.onClose();
  }
}
