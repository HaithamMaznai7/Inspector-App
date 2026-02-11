import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/features/inspection_steps/components/step_selector.dart';
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
        return DefaultTabController(
          length: controller.isLoading.value ? 1 : controller.tabs.length,
          child: Scaffold(
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

              // centerTitle: true,
              // actions: [
              //   IconButton(
              //     onPressed: () => controller.share(),
              //     icon: Icon(Icons.share, color: FColors.white),
              //   ),
              // ],
              leading: BackPageButton(color: FColors.white),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(FSizes.lg * 4),
                child: GetBuilder<InspectionStepsController>(
                  init: InspectionStepsBinding().instance,
                  builder: (controller) {
                    if (controller.isLoading.value) {
                      return SizedBox();
                    }

                    return TabBar(
                      controller: controller.tabController,
                      tabs: controller.tabs.asMap().entries
                          .map(
                            (entry) {
                              final tabIndex = entry.key;
                              final tab = entry.value;
                              final isUnlocked = tabIndex <= controller.highestReachedIndex;
                              return Tab(
                                icon: Icon(
                                  tab['icon'] as IconData,
                                  color: isUnlocked
                                      ? FColors.white
                                      : FColors.white.withValues(alpha: 0.3),
                                  size: FSizes.iconLg,
                                ),
                                iconMargin: EdgeInsets.all(FSizes.sm),
                                child: Text(
                                  tab['id'] == 0
                                      ? 'Inspection Info'
                                      : 'Step ${(tab['id'])}',
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color: isUnlocked
                                            ? FColors.white
                                            : FColors.white.withValues(alpha: 0.3),
                                      ),
                                ),
                              );
                            },
                          )
                          .toList(),
                      onTap: (value) {
                        if (value <= controller.highestReachedIndex) {
                          controller.tabController?.animateTo(value);
                        } else {
                          controller.tabController?.animateTo(controller.currentIndex);
                        }
                      },
                      indicatorColor: FColors.white,
                    );
                  },
                ),
              ),
            ),
            body: GetBuilder<InspectionStepsController>(
              init: InspectionStepsBinding().instance,
              builder: (controller) {
                if (controller.isLoading.value) {
                  return TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          color: FColors.primaryColor,
                        ),
                      ),
                    ],
                  );
                }

                return TabBarView(
                  controller: controller.tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: controller.tabs
                      .map((tab) => tab['screen'] as Widget)
                      .toList(),
                );
              },
            ),
            bottomNavigationBar: StepSelector(),
          ),
        );
      },
    );
  }
}
