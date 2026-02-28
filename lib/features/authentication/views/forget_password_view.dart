import 'package:fahis_inspector/common/styles/spacing_style.dart';
import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ForgetBinding().instance;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: FHelper.isDarkMode(context)
            ? FColors.dark
            : FColors.white,
        leading: BackPageButton(route: RoutingUrl.login),
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
                        // Logo + Subtitle
                        Column(
                          children: [
                            const Logo(height: FSizes.logoHeightLg),
                            const SizedBox(height: FSizes.spaceBtwItems),
                            Text(
                              LoginPage.loginTitle.tr,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              ForgetPage.forgetSubTitle.tr,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),

                        // Form
                        Form(
                          key: controller.formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              Obx(
                                () => TextFormField(
                                  keyboardType: TextInputType.phone,
                                  controller: controller.mobileController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.phone_iphone),
                                    labelText: LoginPage.phoneNumber.tr,
                                    errorText: controller.mobileError.value,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  onSaved: (value) =>
                                      controller.mobile = value!,
                                  validator: (value) =>
                                      FValidation.validatePhoneNo(
                                        'mobile',
                                        value,
                                      ),
                                ),
                              ),
                              const SizedBox(
                                height: FSizes.spaceBtwInputFields,
                              ),

                              Obx(() {
                                final isLoad = controller.isSignIn.value;
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
