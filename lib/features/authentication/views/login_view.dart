import 'package:fahis_inspector/boot/app_service_provider.dart';
import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:fahis_inspector/common/styles/spacing_style.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:fahis_inspector/util/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class Login extends StatelessWidget {
  const Login({super.key});
  @override
  Widget build(BuildContext context) {
    // dd(storage().auth.get('user'));
    dd(Get.isRegistered<AppServiceProvider>(tag: BindingTags.app));
    final controller = LoginBinding().instance;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: FHelper.isDarkMode(context)
            ? FColors.dark
            : FColors.white,
        actions: [FLocalization.localizeIcon(), FLocalization.themeMode()],
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
                                  controller: controller.credentialController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(r'\s'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Iconsax.user),
                                    labelText: LoginPage.username.tr,
                                    errorText: controller.credentialError.value,
                                  ),
                                  validator: (value) =>
                                      FValidation.isRequired(
                                        'credential',
                                        value,
                                      ) ??
                                      (GetUtils.isEmail(value!)
                                          ? FValidation.validateEmail(
                                              'credential',
                                              value,
                                            )
                                          : FValidation.validatePhoneNo(
                                              'credential',
                                              value,
                                            )),
                                  onChanged: (value) {
                                    if (controller.isExists.value) {
                                      controller.toggleIsExists();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: FSizes.spaceBtwInputFields,
                              ),
                              Obx(() {
                                final isEmail = controller.isExists.value;

                                return AnimatedSize(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  child: AnimatedOpacity(
                                    opacity: isEmail ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: isEmail
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                controller: controller
                                                    .passwordController,
                                                obscureText: controller
                                                    .isPasswordHidden
                                                    .value,
                                                decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                    Iconsax.password_check,
                                                  ),
                                                  labelText:
                                                      LoginPage.password.tr,
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      controller
                                                              .isPasswordHidden
                                                              .value
                                                          ? Iconsax.eye
                                                          : Iconsax.eye_slash,
                                                    ),
                                                    onPressed: controller
                                                        .passwordVisibleChange,
                                                  ),
                                                  errorText: controller
                                                      .passwordError
                                                      .value,
                                                ),
                                              ),
                                              const SizedBox(
                                                height:
                                                    FSizes.spaceBtwInputFields,
                                              ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                );
                              }),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => Get.offAllNamed(
                                      RoutingUrl.forgetPassword,
                                    ),
                                    child: Text(
                                      LoginPage.forgetBTN.tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: FColors.info),
                                    ),
                                  ),
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
