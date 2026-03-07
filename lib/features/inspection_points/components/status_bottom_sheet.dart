import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class StatusBottomSheet extends StatelessWidget {
  const StatusBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              InspectionPage.selectStatus.tr,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: FSizes.lg),
            // Good button
            _StatusButton(
              label: FTexts.good.tr,
              icon: Iconsax.chart_success,
              color: FColors.success,
              onTap: () => Get.back<PointStatus>(result: PointStatus.good),
            ),
            const SizedBox(height: FSizes.sm),
            // Note button
            _StatusButton(
              label: FTexts.notes.tr,
              icon: Iconsax.note,
              color: FColors.warning,
              onTap: () => Get.back<PointStatus>(result: PointStatus.note),
            ),
            const SizedBox(height: FSizes.sm),
            // N/A button
            _StatusButton(
              label: FTexts.na.tr,
              icon: Iconsax.box_remove,
              color: FColors.darkGrey,
              onTap: () => Get.back<PointStatus>(result: PointStatus.none),
            ),
            const SizedBox(height: FSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: FSizes.buttonHeightLg,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: FSizes.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
