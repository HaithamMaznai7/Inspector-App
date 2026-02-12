import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class GenerateDialog extends StatelessWidget {
  const GenerateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: FColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.warning_2,
                color: FColors.warning,
                size: 32,
              ),
            ),
            const SizedBox(height: FSizes.md),
            // Title
            Text(
              InspectionPage.resetPointsTitle.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.sm),
            // Content
            Text(
              InspectionPage.resetPointsContent.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: FColors.darkerGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.lg),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      side: const BorderSide(color: FColors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                      ),
                    ),
                    child: Text(
                      FTexts.cancelBtn.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: FColors.darkerGrey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                      ),
                    ),
                    child: Text(
                      InspectionPage.resetPointsConfirm.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}