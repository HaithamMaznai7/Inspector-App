import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Card displaying a company name, vehicle count, and status summary.
/// Tapping navigates to the company's inspection list.
class CompanyCard extends StatelessWidget {
  final String companyName;
  final int totalVehicles;
  final int completedCount;
  final int inProgressCount;
  final int rejectedCount;
  final VoidCallback onTap;

  const CompanyCard({
    super.key,
    required this.companyName,
    required this.totalVehicles,
    required this.completedCount,
    required this.inProgressCount,
    required this.rejectedCount,
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
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.md),

              // Company name + vehicle count + status row
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
                      '$totalVehicles ${'Vehicles'.tr}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: FColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: FSizes.xs),
                    _buildStatusRow(context),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Iconsax.arrow_right_3,
                size: FSizes.fontSizeLg,
                color: FColors.darkGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Colored status chips: Completed • In Progress • Rejected
  Widget _buildStatusRow(BuildContext context) {
    final chips = <Widget>[];

    if (completedCount > 0) {
      chips.add(_statusChip(context, '$completedCount ${'Completed'.tr}', Colors.green));
    }
    if (inProgressCount > 0) {
      chips.add(_statusChip(context, '$inProgressCount ${'In Progress'.tr}', Colors.orange));
    }
    if (rejectedCount > 0) {
      chips.add(_statusChip(context, '$rejectedCount ${'Rejected'.tr}', Colors.red));
    }

    if (chips.isEmpty) {
      chips.add(_statusChip(context, 'Pending'.tr, FColors.darkGrey));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: chips,
    );
  }

  Widget _statusChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
