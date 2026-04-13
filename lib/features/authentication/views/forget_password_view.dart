import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:fahis_inspector/util/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ForgetBinding().instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet =
        ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackPageButton(route: RoutingUrl.login),
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
                                ForgetPage.forgetSubTitle.tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
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
                            margin: const EdgeInsets.only(top: FSizes.xl),
                            padding: const EdgeInsets.all(FSizes.lg),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.025)
                                  : Colors.black.withValues(alpha: 0.015),
                              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Form(
                              key: controller.formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                          borderRadius:
                                              BorderRadius.circular(FSizes.xxs),
                                        ),
                                      ),
                                      const SizedBox(width: FSizes.sm),
                                      Text(
                                        LoginPage.verifyOTP.tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: FSizes.spaceBtwItems),

                                  // Phone field
                                  Obx(
                                    () => TextFormField(
                                      keyboardType: TextInputType.phone,
                                      controller: controller.mobileController,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                            Icons.phone_iphone_rounded),
                                        labelText: LoginPage.phoneNumber.tr,
                                        errorText:
                                            controller.mobileError.value,
                                      ),
                                      onSaved: (value) =>
                                          controller.mobile = value!,
                                      validator: (value) =>
                                          FValidation.validatePhoneNo(
                                              'mobile', value),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: FSizes.spaceBtwInputFields),

                                  // Submit button / loading
                                  Obx(() {
                                    final isLoad = controller.isSignIn.value;
                                    if (isLoad) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: FColors.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                              FSizes.borderRadiusMd),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: FSizes.sm),
                                        width: double.infinity,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                              color: FColors.white),
                                        ),
                                      );
                                    }
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: controller.checkLogin,
                                        child: Text(
                                          LoginPage.verifyOTP.tr,
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
