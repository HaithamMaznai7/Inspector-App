import 'package:fahis_inspector/Common/styles/spacing_style.dart';
import 'package:fahis_inspector/Common/widget/logo.dart';
import 'package:fahis_inspector/features/authentication/screens/widget/page_toggle_btn.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:fahis_inspector/util/validators/validation.dart';
import 'package:fahis_inspector/features/authentication/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class Login extends GetView<LoginController> {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: FHelper.isDarkMode(context)
            ? FColors.dark
            : FColors.white,
        leading: Row(
          children: [FLocalization.localizeIcon(), FLocalization.themeMode()],
        ),
        leadingWidth: 140,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: FSpacingStyle.paddingWithAppBarHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo + title
                        Column(
                          children: [
                            const Logo(height: 80),
                            const SizedBox(height: FSizes.spaceBtwItems),
                            Text(
                              LoginPage.loginTitle.tr,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              LoginPage.loginSubTitle.tr,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),

                        // Form + login button
                        Form(
                          key: controller.loginFormKey,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          child: Column(
                            children: [
                              Obx(
                                () => TextFormField(
                                  controller: controller.emailController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Iconsax.user),
                                    labelText: LoginPage.username.tr,
                                    errorText: controller.emailError.value,
                                  ),
                                  validator: FValidation.validate,
                                ),
                              ),
                              const SizedBox(
                                height: FSizes.spaceBtwInputFields,
                              ),
                              Obx(
                                () => TextFormField(
                                  controller: controller.passwordController,
                                  obscureText:
                                      controller.isPasswordHidden.value,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Iconsax.password_check,
                                    ),
                                    labelText: LoginPage.password.tr,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isPasswordHidden.value
                                            ? Iconsax.eye
                                            : Iconsax.eye_slash,
                                      ),
                                      onPressed:
                                          controller.passwordVisibleChange,
                                    ),
                                    errorText: controller.passwordError.value,
                                  ),
                                  validator: (value) =>
                                      FValidation.validatePassword(value!),
                                ),
                              ),
                              const SizedBox(
                                height: FSizes.spaceBtwInputFields,
                              ),
                              Row(
                                children: [
                                  Obx(
                                    () => Checkbox(
                                      value: controller.rememberMe.value,
                                      onChanged: (_) =>
                                          controller.rememberMe.toggle(),
                                    ),
                                  ),
                                  Text(LoginPage.rememberMe.tr),
                                ],
                              ),
                              const SizedBox(height: FSizes.spaceBtwItems),
                              Obx(() {
                                final isLoad = controller.isLoading.value;
                                if (isLoad) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: FColors.primaryColor,
                                      borderRadius: BorderRadius.circular(
                                        FSizes.borderRadiusMd,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: FSizes.sm,
                                    ),
                                    width: double.infinity,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: FColors.white,
                                      ),
                                    ),
                                  );
                                }

                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => controller.checkLogin(),
                                    child: Text(
                                      LoginPage.signIn.tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.apply(color: FColors.white),
                                    ),
                                  ),
                                );
                              }),

                              const SizedBox(height: FSizes.spaceBtwItems),
                              PageToggleBtn(
                                btnTitle: LoginPage.forgetBTN.tr,
                                onPressed: controller.forgetPassword,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
