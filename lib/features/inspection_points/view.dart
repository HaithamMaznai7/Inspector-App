import 'package:fahis_inspector/features/inspection_points/controller.dart';
import 'package:fahis_inspector/models/review_point.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionPointResults extends StatelessWidget {
  const InspectionPointResults({super.key});

  Widget _buildBadge(String value, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String iconUrl) {
    return SvgPicture.network(
      iconUrl,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      colorFilter: const ColorFilter.mode(
        FColors.primaryColor,
        BlendMode.srcIn,
      ),
      placeholderBuilder: (context) => SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: FColors.primaryColor,
        ),
      ),
      errorBuilder: (context, error, stackTrace) => Icon(
        Iconsax.category,
        size: 24,
        color: FColors.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionPointsController>(
      init: InspectionPointsBinding().instance,
      builder: (controller) {
        final review = controller.review.value ?? ReviewPoint.set([]);
        final isLoading = controller.isLoading.value;
        if (isLoading) {
          return Center(
            child: CircularProgressIndicator(color: FColors.primaryColor),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.sm,
            ),
            children: [
              // Header card with summary
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  side: BorderSide(color: FColors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => controller.generate(),
                        icon: const Icon(Iconsax.refresh),
                        tooltip: InspectionPage.resetPointsTitle.tr,
                        style: IconButton.styleFrom(
                          backgroundColor: FColors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                          ),
                        ),
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: Text(
                          InspectionPage.pointsReview.tr,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          _buildBadge('${review.good}', FColors.success),
                          const SizedBox(width: FSizes.xs),
                          _buildBadge('${review.note}', FColors.warning),
                          const SizedBox(width: FSizes.xs),
                          _buildBadge('${review.none}', FColors.darkGrey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: FSizes.xs),

              // Category list
              ...review.cats.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(bottom: FSizes.xs),
                  child: Card(
                    elevation: 1,
                    shadowColor: FColors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    ),
                    child: InkWell(
                      onTap: () => controller.onEdit(cat: cat),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.md,
                          vertical: FSizes.md,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: FColors.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                              ),
                              alignment: Alignment.center,
                              child: _buildCategoryIcon(cat.category.icon),
                            ),
                            const SizedBox(width: FSizes.md),
                            Expanded(
                              child: Text(
                                cat.category.title,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              textDirection: TextDirection.ltr,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildBadge('${cat.good}', FColors.success),
                                const SizedBox(width: FSizes.xs),
                                _buildBadge('${cat.note}', FColors.warning),
                                const SizedBox(width: FSizes.xs),
                                _buildBadge('${cat.none}', FColors.darkGrey),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
