import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  /// Controllers
  TextEditingController credentialController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final credentialError = RxnString();
  final passwordError = RxnString();

  /// Variables
  var credential = '';
  var password = '';
  String phoneNO = '';

  /// Flags
  RxBool isLoading = false.obs;
  RxBool isExists = false.obs;
  RxBool isvalidatePassword = false.obs;
  RxBool isPasswordHidden = true.obs;

  void toggleLoading() => isLoading.toggle();
  void toggleIsExists() => isExists.toggle();
  void passwordVisibleChange() => isPasswordHidden.toggle();

  void forgetPassword() => Get.offAllNamed(RoutingUrl.forgetPassword);

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> checkLogin() async {
    credential = credentialController.text.trim();

    final isValid = loginFormKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    loginFormKey.currentState!.save();

    await login();
  }

  Future<void> login() async {
    toggleLoading();
    password = passwordController.text;
    credentialError.value = null;
    passwordError.value = null;

    try {
      await auth().login(credential, password);
    } on FNetworkException catch (e) {
      if (e.statusCode == 422 && e.errors != null) {
        isExists.value =
            !e.errors!.containsKey('email') && !e.errors!.containsKey('mobile');
        if (!isExists.value) {
          // check if user exists
          credentialError.value =
              e.errors!['email'][0] ?? e.errors!['mobile'][0];
          isExists.value = true;
          isvalidatePassword.value = false;
          return;
        } else{
          isvalidatePassword.value = true;
        }

        if (passwordError.value == null && isvalidatePassword.value && e.errors!.containsKey('password')) {
          passwordError.value = e.errors!['password'][0];
          return;
        } else {
          password = '';
          passwordController.text = '';
        }
      }
    } on FirebaseAuthException catch (e) {
      dd(e);
    } catch (e) {
      throw e;
      // dd(e.toString());
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
    credentialController.dispose();

    passwordController.dispose();

    super.onClose();
  }
}
