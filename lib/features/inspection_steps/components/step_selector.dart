import 'package:fahis_inspector/features/inspection_steps/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepSelector extends StatelessWidget {
  const StepSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GetBuilder<InspectionStepsController>(
      init: InspectionStepsBinding().instance,
      builder: (controller) {
        final submitting = controller.isSubmitting.value;
        final showBack = !controller.isOnFirstTab;
        final showReview = controller.isOnLastTab;

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : FColors.grey)
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.lg,
                vertical: FSizes.md,
              ),
              child: showReview
                  ? _buildButton(
                      context: context,
                      onPressed:
                          submitting ? null : controller.finishAndReview,
                      isLoading: submitting,
                      label: FTexts.reviewBtn.tr,
                    )
                  : Row(
                      children: [
                        if (showBack) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: submitting
                                  ? null
                                  : controller.toPervious,
                              child: Text(FTexts.backBtn.tr),
                            ),
                          ),
                          const SizedBox(width: FSizes.spaceBtwItems),
                        ],
                        Expanded(
                          flex: showBack ? 2 : 1,
                          child: _buildButton(
                            context: context,
                            onPressed:
                                submitting ? null : controller.toNext,
                            isLoading: submitting,
                            label: FTexts.nextBtn.tr,
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

  Widget _buildButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required bool isLoading,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: isLoading
          ? const SizedBox(
              width: FSizes.iconInlineSm,
              height: FSizes.iconInlineSm,
              child: CircularProgressIndicator(
                color: FColors.white,
                strokeWidth: 2,
              ),
            )
          : Text(label),
    );
  }
}
