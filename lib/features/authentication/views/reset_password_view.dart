import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:fahis_inspector/features/authentication/controllers/reset_password_controller.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:fahis_inspector/util/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet =
        ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor:
          isDark ? FColors.dark : const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: Row(
          children: [FLocalization.localizeIcon(), FLocalization.themeMode()],
        ),
        leadingWidth: 140,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 0 : 24,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Branding ──────────────────────────────────
                  const Center(child: Logo(height: 64)),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'resetPassword'.tr,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'resetPasswordSubtitle'.tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? FColors.grey : FColors.darkGrey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Form card ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Form(
                      key: controller.formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: FColors.primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'resetPassword'.tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // New password field
                          Obx(
                            () => TextFormField(
                              controller: controller.passwordController,
                              obscureText: !controller.showPassword.value,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: 'newPassword'.tr,
                                prefixIcon: const Icon(Iconsax.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.showPassword.value
                                        ? Iconsax.eye
                                        : Iconsax.eye_slash,
                                    size: 20,
                                  ),
                                  onPressed: () => controller.showPassword
                                      .value = !controller.showPassword.value,
                                ),
                              ),
                              validator: (v) => FValidation.validatePassword(
                                'newPassword'.tr,
                                v,
                              ),
                            ),
                          ),
                          const SizedBox(height: FSizes.spaceBtwInputFields),

                          // Confirm password field
                          Obx(
                            () => TextFormField(
                              controller:
                                  controller.passwordConfirmationController,
                              obscureText:
                                  !controller.showPasswordConfirmation.value,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: 'confirmPassword'.tr,
                                prefixIcon: const Icon(Iconsax.lock_1),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.showPasswordConfirmation.value
                                        ? Iconsax.eye
                                        : Iconsax.eye_slash,
                                    size: 20,
                                  ),
                                  onPressed: () => controller
                                      .showPasswordConfirmation.value =
                                      !controller
                                          .showPasswordConfirmation.value,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'confirmPassword'.tr;
                                }
                                if (v != controller.passwordController.text) {
                                  return 'passwordMismatch'.tr;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: FSizes.spaceBtwSections),

                          // Submit button
                          Obx(() {
                            final loading = controller.isLoading.value;
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    loading ? null : controller.resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FColors.primaryColor,
                                  foregroundColor: FColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        FSizes.borderRadiusMd),
                                  ),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: FColors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        FTexts.saveBtn.tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: FColors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
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
  }
}
