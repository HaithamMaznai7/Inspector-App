import 'package:fahis_inspector/features/inspection_points/components/card.dart';
import 'package:fahis_inspector/features/inspection_points/controller.dart';
import 'package:fahis_inspector/models/point_category.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Full-session editing screen.
///
/// The user arrives here by tapping any category row in [InspectionPointResults].
/// Instead of going back to pick the next category, they can:
///   - Tap a chip in the top tab strip to jump to any category directly.
///   - Tap "Next" at the bottom to advance to the next category.
///   - Tap "Back" to return to the previous category.
///   - Tap "Done" (shown only on the last category) to finish and pop.
///
/// This removes the repetitive navigate-back → tap → navigate-forward loop.
class InspectionPointsScreen extends StatelessWidget {
  const InspectionPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          const _CategoryTabStrip(),
          const Expanded(child: _PointsList()),
        ],
      ),
      bottomNavigationBar: const _CategoryNavBar(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: FColors.primaryGradient),
      ),
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
      ),
      title: GetBuilder<InspectionPointsController>(
        init: InspectionPointsBinding().instance,
        builder: (controller) {
          final cat = controller.category.value;
          final idx = controller.currentCategoryIndex;
          final total = controller.categories.length;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cat?.category.title ??
                    InspectionPage.inspectionDetailsTitle.tr,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: FColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              if (total > 1)
                Text(
                  '${idx + 1} / $total',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.white70),
                ),
            ],
          );
        },
      ),
      centerTitle: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category tab strip
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryTabStrip extends StatelessWidget {
  const _CategoryTabStrip();

  Color _statusColor(PointCategory cat) {
    final total = cat.good + cat.note + cat.none;
    final answered = cat.good + cat.note;
    if (total == 0) return FColors.darkGrey;
    if (answered == total) return FColors.success;
    if (answered > 0) return FColors.warning;
    return FColors.darkGrey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<InspectionPointsController>(
      init: InspectionPointsBinding().instance,
      builder: (controller) {
        final cats = controller.categories;
        final currentId = controller.category.value?.category.id;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.sm,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cats.map((cat) {
                final isSelected = cat.category.id == currentId;
                final total = cat.good + cat.note + cat.none;
                final answered = cat.good + cat.note;
                final statusColor = _statusColor(cat);

                return Padding(
                  padding:
                      const EdgeInsetsDirectional.only(end: FSizes.xs),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.category.title),
                        const SizedBox(width: FSizes.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$answered/$total',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: FColors.primaryColor,
                    backgroundColor:
                        FColors.primaryColor.withValues(alpha: 0.08),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : FColors.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? FColors.primaryColor
                          : FColors.primaryColor.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(FSizes.borderRadiusLg),
                    ),
                    onSelected: (_) => controller.setCategory(cat),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Points list for the current category
// ─────────────────────────────────────────────────────────────────────────────

class _PointsList extends StatelessWidget {
  const _PointsList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionPointsController>(
      init: InspectionPointsBinding().instance,
      builder: (controller) {
        final category = controller.category.value;

        if (category == null) {
          return Center(
            child: CircularProgressIndicator(color: FColors.primaryColor),
          );
        }

        final points = category.points;

        if (points.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.clipboard_text,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                ),
                const SizedBox(height: FSizes.sm),
                Text(
                  InspectionPage.noPhotosYet.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.45),
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          // Reset scroll position when switching categories
          key: ValueKey(category.category.id),
          padding: const EdgeInsets.fromLTRB(
            FSizes.md,
            FSizes.md,
            FSizes.md,
            FSizes.lg,
          ),
          itemCount: points.length,
          itemBuilder: (context, index) {
            final point = points[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: FSizes.sm),
              child: PointCard(
                key: ValueKey(point.id),
                point: point,
                onChange: controller.onChangePoint,
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom category navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryNavBar extends StatelessWidget {
  const _CategoryNavBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GetBuilder<InspectionPointsController>(
      init: InspectionPointsBinding().instance,
      builder: (controller) {
        final isFirst = controller.isOnFirstCategory;
        final isLast = controller.isOnLastCategory;

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
              child: Row(
                children: [
                  if (!isFirst) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.toPreviousCategory,
                        child: Text(FTexts.backBtn.tr),
                      ),
                    ),
                    const SizedBox(width: FSizes.spaceBtwItems),
                  ],
                  Expanded(
                    flex: isFirst ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: isLast
                          ? () => Get.back()
                          : controller.toNextCategory,
                      child: Text(
                        isLast
                            ? InspectionPage.doneBtn.tr
                            : FTexts.nextBtn.tr,
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
