import 'package:fahis_inspector/features/inspection_steps/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepSelector extends StatelessWidget {
  const StepSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionStepsController>(
      init: InspectionStepsBinding().instance,
      builder: (controller) {
        final submitting = controller.isSubmitting.value;
        final showBack = !controller.isOnFirstTab;
        final showReview = controller.isOnLastTab;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: FDeviceUtils.getScreenWidth() * .9,
              child: showReview
                  ? ElevatedButton(
                      onPressed: submitting
                          ? null
                          : controller.finishAndReview,
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: FSizes.md,
                        ),
                        child: submitting
                            ? SizedBox(
                                width: FSizes.iconInlineSm,
                                height: FSizes.iconInlineSm,
                                child: CircularProgressIndicator(
                                  color: FColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(FTexts.reviewBtn.tr),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (showBack) ...[
                          Expanded(
                            child: ElevatedButton(
                              style: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .copyWith(
                                    backgroundColor: WidgetStateProperty.all(
                                      FColors.darkGrey,
                                    ),
                                  ),
                              onPressed:
                                  submitting ? null : controller.toPervious,
                              child: Padding(
                                padding: EdgeInsetsGeometry.symmetric(
                                  horizontal: FSizes.md,
                                ),
                                child: Text(FTexts.backBtn.tr),
                              ),
                            ),
                          ),
                          SizedBox(width: FSizes.spaceBtwItems),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: submitting
                                ? null
                                : controller.toNext,
                            child: Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                horizontal: FSizes.md,
                              ),
                              child: submitting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: FColors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(FTexts.nextBtn.tr),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
