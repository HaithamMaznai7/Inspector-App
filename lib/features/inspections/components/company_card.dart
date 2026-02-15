import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Card displaying a company name, request count, and stage summary.
/// Tapping navigates to the company's inspection list.
class CompanyCard extends StatelessWidget {
  final String companyName;
  final List<Inspection> inspections;
  final VoidCallback onTap;

  const CompanyCard({
    super.key,
    required this.companyName,
    required this.inspections,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      child: Card(
        color: isDark ? FColors.black : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.md),
          child: Row(
            children: [
              // Company icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FColors.primaryColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Iconsax.building_3,
                  color: FColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: FSizes.md),

              // Company name + request count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? FColors.grey : FColors.textPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: FSizes.xs),
                    Text(
                      '${inspections.length} ${'requests'.tr}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: FColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),

              // Stage badges summary
              _buildStageSummary(context),

              const SizedBox(width: FSizes.sm),

              // Arrow icon
              Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: FColors.darkGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows small colored dots summarizing the stages of requests
  Widget _buildStageSummary(BuildContext context) {
    // Count inspections per stage
    final Map<String, int> stageCounts = {};
    for (final ins in inspections) {
      final label = ins.stage.label;
      stageCounts[label] = (stageCounts[label] ?? 0) + 1;
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: stageCounts.entries.take(3).map((entry) {
        // Find the matching inspection to get color
        final color = inspections
            .firstWhere((i) => i.stage.label == entry.key)
            .stage
            .color;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
          ),
          child: Text(
            '${entry.value}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      }).toList(),
    );
  }
}
