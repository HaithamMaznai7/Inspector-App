import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/features/inspection_steps/components/step_selector.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/features/inspection_steps/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InspectionStepsScreen extends StatelessWidget {
  const InspectionStepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionStepsController>(
      init: InspectionStepsBinding().instance,
      autoRemove: true,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: FColors.primaryGradient,
              ),
            ),
            title: Text(
              DetailsPage.pageTitle.trParams({
                'inspection': controller.inspection.value.slug,
              }),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.apply(color: FColors.white),
            ),
            leading: BackPageButton(color: FColors.white),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(FSizes.lg * 3),
              child: controller.isLoading.value
                  ? const SizedBox()
                  : _StepIndicatorRow(controller: controller),
            ),
          ),
          body: controller.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(color: FColors.primaryColor),
                )
              : IndexedStack(
                  index: controller.index,
                  children: controller.tabs
                      .map((tab) => tab['screen'] as Widget)
                      .toList(),
                ),
          bottomNavigationBar: StepSelector(),
        );
      },
    );
  }
}

class _StepIndicatorRow extends StatelessWidget {
  final InspectionStepsController controller;

  const _StepIndicatorRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final tabs = controller.tabs;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.sm,
      ),
      child: Row(
        children: List.generate(tabs.length * 2 - 1, (i) {
          if (i.isOdd) {
            final prevIndex = i ~/ 2;
            final isCompleted = prevIndex < controller.highestReachedIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? FColors.white
                    : FColors.white.withValues(alpha: 0.3),
              ),
            );
          }

          final tabIndex = i ~/ 2;
          final tab = tabs[tabIndex];
          final isActive = tabIndex == controller.index;
          final isCompleted =
              tabIndex < controller.index &&
              tabIndex <= controller.highestReachedIndex;
          final isReachable = tabIndex <= controller.highestReachedIndex;

          return GestureDetector(
            onTap: isReachable ? () => controller.goToTab(tabIndex) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: FSizes.loadingIndicatorSize,
                  height: FSizes.loadingIndicatorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? FColors.white
                        : isCompleted
                        ? FColors.white.withValues(alpha: 0.85)
                        : Colors.transparent,
                    border: Border.all(
                      color: isReachable
                          ? FColors.white
                          : FColors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted && !isActive
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: FColors.primaryColor,
                          )
                        : Icon(
                            tab['icon'] as IconData,
                            size: 18,
                            color: isActive
                                ? FColors.primaryColor
                                : isReachable
                                ? FColors.white
                                : FColors.white.withValues(alpha: 0.3),
                          ),
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  // Show the stage name (e.g. "Points", "Photos")
                  // instead of "Step N" to avoid confusion on partial orders
                  (tab['stage'] as InspectionStage).getLabel,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: isReachable
                        ? FColors.white
                        : FColors.white.withValues(alpha: 0.3),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
