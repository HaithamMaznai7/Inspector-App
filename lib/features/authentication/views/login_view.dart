import 'package:fahis_inspector/boot/app_service_provider.dart';
import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:fahis_inspector/util/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    dd(Get.isRegistered<AppServiceProvider>(tag: BindingTags.app));
    final controller = LoginBinding().instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [FLocalization.localizeIcon(), FLocalization.themeMode()],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 480 : double.infinity,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 0 : FSizes.lg,
                        vertical: FSizes.md,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ── Branding ─────────────────────────────────
                          Column(
                            children: [
                              const Logo(height: FSizes.logoHeightLg),
                              const SizedBox(height: FSizes.spaceBtwItems),
                              Text(
                                LoginPage.loginTitle.tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: FSizes.xs),
                              Text(
                                LoginPage.loginSubTitle.tr,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? FColors.grey
                                          : FColors.darkGrey,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          // ── Form card ─────────────────────────────────
                          Container(
                            margin: const EdgeInsets.only(top: FSizes.iconCircleSm),
                            padding: const EdgeInsets.all(FSizes.lg),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.025)
                                  : Colors.black.withValues(alpha: 0.025),
                              borderRadius: BorderRadius.circular(FSizes.iconInlineSm),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Form(
                              key: controller.loginFormKey,
                              autovalidateMode: AutovalidateMode.onUnfocus,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Card header
                                  Row(
                                    children: [
                                      Container(
                                        width: 3,
                                        height: FSizes.md,
                                        decoration: BoxDecoration(
                                          color: FColors.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            FSizes.xxs,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: FSizes.sm),
                                      Text(
                                        LoginPage.signIn.tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: FSizes.iconInlineSm),

                                  // Credential field
                                  Obx(
                                    () => TextFormField(
                                      controller:
                                          controller.credentialController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                          RegExp(r'\s'),
                                        ),
                                      ],
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Iconsax.user),
                                        labelText: LoginPage.username.tr,
                                        errorText:
                                            controller.credentialError.value,
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
                                    ),
                                  ),
                                  const SizedBox(
                                    height: FSizes.spaceBtwInputFields,
                                  ),

                                  // Password field
                                  Obx(
                                    () => TextFormField(
                                      controller:
                                          controller.passwordController,
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
                                        errorText:
                                            controller.passwordError.value,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'fieldRequired'.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: FSizes.spaceBtwInputFields,
                                  ),

                                  // Forgot password
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
                                              .bodyMedium
                                              ?.copyWith(
                                                color: FColors.info,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: FSizes.spaceBtwItems),

                                  // Login button / loading
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
                                        padding: const EdgeInsets.symmetric(
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
                                        onPressed: () =>
                                            controller.checkLogin(),
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
                          ),
                        ],
                      ),
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
