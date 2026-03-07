import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OBDCodeCard extends StatelessWidget {
  final OBDCode code;

  const OBDCodeCard({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return InkWell(
      onTap: () => InspectionObdBinding().instance.onCreateEdit(code: code),
      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      child: Container(
        margin: const EdgeInsets.only(bottom: FSizes.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? FColors.darkGrey.withValues(alpha: 0.25)
              : FColors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: isDark
                ? FColors.grey.withValues(alpha: 0.12)
                : FColors.grey.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            // Code badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: FColors.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                border: Border.all(
                  color: FColors.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                code.code,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: FColors.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: FSizes.sm),
            // Description
            Expanded(
              child: Text(
                code.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? FColors.light : FColors.dark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: FSizes.xs),
            // Delete button
            GestureDetector(
              onTap: () => InspectionObdBinding().instance.delete(code),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: FColors.error.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.trash,
                  size: 15,
                  color: FColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
