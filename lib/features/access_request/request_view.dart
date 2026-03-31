import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:fahis_inspector/util/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class RequestAccessScreen extends StatelessWidget {
  const RequestAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AccessRequestBinding().instance;
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
        leading: IconButton(
          onPressed: () => Get.offAllNamed(RoutingUrl.login),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          AccessRequestPage.requestFormTitle.tr,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
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
                        horizontal: isTablet ? 0 : FSizes.defaultSpace,
                        vertical: FSizes.md,
                      ),
                      child: Form(
                        key: controller.formKey,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: FSizes.sm),

                            // ── Full Name ──
                            TextFormField(
                              controller: controller.nameController,
                              decoration: InputDecoration(
                                labelText: AccessRequestPage.fullName.tr,
                                hintText: AccessRequestPage.fullNameHint.tr,
                                prefixIcon: const Icon(Iconsax.user),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) => FValidation.isRequired(
                                AccessRequestPage.fullName.tr,
                                value,
                              ),
                            ),
                            const SizedBox(height: FSizes.spaceBtwInputFields),

                            // ── Email ──
                            TextFormField(
                              controller: controller.emailController,
                              decoration: InputDecoration(
                                labelText: AccessRequestPage.email.tr,
                                hintText: AccessRequestPage.emailHint.tr,
                                prefixIcon: const Icon(Iconsax.sms),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  FValidation.isRequired(
                                    AccessRequestPage.email.tr,
                                    value,
                                  ) ??
                                  FValidation.validateEmail(
                                    AccessRequestPage.email.tr,
                                    value!,
                                  ),
                            ),
                            const SizedBox(height: FSizes.spaceBtwInputFields),

                            // ── Phone ──
                            TextFormField(
                              controller: controller.phoneController,
                              decoration: InputDecoration(
                                labelText: AccessRequestPage.phone.tr,
                                hintText: AccessRequestPage.phoneHint.tr,
                                prefixIcon: const Icon(Iconsax.call),
                              ),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  FValidation.isRequired(
                                    AccessRequestPage.phone.tr,
                                    value,
                                  ) ??
                                  FValidation.validatePhoneNo(
                                    AccessRequestPage.phone.tr,
                                    value!,
                                  ),
                            ),
                            const SizedBox(height: FSizes.spaceBtwInputFields),

                            // ── City ──
                            TextFormField(
                              controller: controller.cityController,
                              decoration: InputDecoration(
                                labelText: AccessRequestPage.city.tr,
                                hintText: AccessRequestPage.cityHint.tr,
                                prefixIcon: const Icon(Iconsax.location),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) => FValidation.isRequired(
                                AccessRequestPage.city.tr,
                                value,
                              ),
                            ),
                            const SizedBox(height: FSizes.spaceBtwInputFields),

                            // ── Note (optional) ──
                            TextFormField(
                              controller: controller.noteController,
                              decoration: InputDecoration(
                                labelText: AccessRequestPage.note.tr,
                                hintText: AccessRequestPage.noteHint.tr,
                                prefixIcon: const Icon(Iconsax.note),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                              textInputAction: TextInputAction.done,
                            ),

                            const SizedBox(height: FSizes.spaceBtwSections),

                            // ── Submit button ──
                            SizedBox(
                              width: double.infinity,
                              child: Obx(
                                () => ElevatedButton(
                                  onPressed: controller.isSubmitting.value
                                      ? null
                                      : controller.submitRequest,
                                  child: controller.isSubmitting.value
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isDark
                                                ? Colors.white
                                                : FColors.primaryColor,
                                          ),
                                        )
                                      : Text(
                                          AccessRequestPage.submitRequest.tr,
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: FSizes.lg),
                          ],
                        ),
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
