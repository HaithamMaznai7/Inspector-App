import 'package:fahis_inspector/common/widgets/skeletons/skeleton.dart';
import 'package:fahis_inspector/features/inspections/components/company_card.dart';
import 'package:fahis_inspector/features/inspections/components/company_inspections_screen.dart';
import 'package:fahis_inspector/features/inspections/components/inspection_card.dart';
import 'package:fahis_inspector/features/inspections/components/on_loading_inspections.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/features/inspections/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/helpers/stage_mapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionList extends StatelessWidget {
  const InspectionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
      child: GetBuilder<InspectionsController>(
        init: InspectionsBinding().instance,
        builder: (controller) {
          final isLoad = controller.isLoading.value;

          // Show shimmer while loading
          if (isLoad) return OnLoadingInspections();

          // Show segments only when stage=All and no search active
          // Otherwise show flat list (search results or stage-filtered)
          return Obx(() {
            final isDefault =
                controller.selectedStage.value == InspectionStage.all &&
                !controller.isSearchActive.value;

            if (!isDefault) {
              return _SearchResultsList(controller: controller);
            }

            return Column(
              children: [
                const SizedBox(height: FSizes.sm),
                // Segmented toggle: Companies / Individuals
                _SegmentToggle(controller: controller),
                const SizedBox(height: FSizes.sm),
                // Show content based on selected segment
                Expanded(
                  child: Obx(
                    () => controller.selectedSegment.value == 0
                        ? _CompanyList(controller: controller)
                        : _IndividualList(controller: controller),
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}

/// Segmented toggle button for switching between Companies and Individuals
class _SegmentToggle extends StatelessWidget {
  final InspectionsController controller;
  const _SegmentToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return Obx(() {
      final selected = controller.selectedSegment.value;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? FColors.darkGrey.withValues(alpha: 0.5)
              : FColors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        child: Row(
          children: [
            // Individuals tab
            _buildTab(
              context,
              label: 'Individuals'.tr,
              isSelected: selected == 1,
              onTap: () => controller.changeSegment(1),
            ),
            // Companies tab
            _buildTab(
              context,
              label: 'Companies'.tr,
              isSelected: selected == 0,
              onTap: () => controller.changeSegment(0),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: FSizes.sm + 2),
          decoration: BoxDecoration(
            color: isSelected ? FColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg - 2),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isSelected ? Colors.white : FColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays B2B orders as company cards with vehicle counts and status summary
class _CompanyList extends StatelessWidget {
  final InspectionsController controller;
  const _CompanyList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingB2B.value && controller.ordersB2B.isEmpty) {
        return OnLoadingInspections();
      }

      final b2bOrders = controller.b2bOrders;

      if (b2bOrders.isEmpty) {
        return _EmptyOrdersState(
          message: 'No company requests'.tr,
          onRefresh: controller.refreshPage,
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: controller.refreshPage,
            color: FColors.primaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: controller.scrollController,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: b2bOrders.map((order) {
                      return CompanyCard(
                        companyName: order.customer.name,
                        totalVehicles: order.meta.total,
                        completedCount: order.meta.finishedCount,
                        inProgressCount: order.meta.processedCount,
                        rejectedCount: order.meta.rejectedCount,
                        onTap: () => Get.to(
                          () => CompanyInspectionsScreen(
                            companyName: order.customer.name,
                            order: order,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Shimmer skeleton while fetching more
                Obx(() {
                  final loading =
                      controller.ordersRepositoryB2B?.isFetchingMore.value ?? false;
                  if (loading) {
                    return Column(
                      children: List.generate(2, (_) => const _CompanyCardSkeleton()),
                    );
                  }
                  return SizedBox();
                }),
              ],
            ),
          );
        },
      );
    });
  }
}

/// Flat list of ALL search results — bypasses company/individual segmentation.
/// Best practice: search should show every match, ignoring active filters.
class _SearchResultsList extends StatelessWidget {
  final InspectionsController controller;
  const _SearchResultsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final list = controller.inspections;

    if (list.isEmpty) {
      return Center(
        child: Text(
          'No results found'.tr,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: FColors.darkGrey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshPage,
      color: FColors.primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final inspection = list[index];
          return InspectionCard(
            slug: inspection.slug,
            customerName: inspection.customer?.name,
            vehicle: inspection.vehicle,
            stage: inspection.stage,
            rejectedNote: inspection.rejectedNote,
            onTap: () => controller.openInspection(inspection),
          );
        },
      ),
    );
  }
}

/// Displays individual (single-request) inspection cards
class _IndividualList extends StatelessWidget {
  final InspectionsController controller;
  const _IndividualList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isOrdersMode = controller.selectedStage.value == InspectionStage.all && 
                         !controller.isSearchActive.value;
    
    if (isOrdersMode) {
      return _buildOrdersList(context);
    } else {
      return _buildInspectionsList(context);
    }
  }

  Widget _buildOrdersList(BuildContext context) {
    final orders = controller.orders;

    if (orders.isEmpty) {
      return _EmptyOrdersState(
        message: 'No individual requests'.tr,
        onRefresh: controller.refreshPage,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: controller.refreshPage,
          color: FColors.primaryColor,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: controller.scrollController,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: orders.expand((order) {
                    return order.items.map((item) => InspectionCard(
                      slug: item.slug,
                      customerName: order.customer.name,
                      vehicle: item.vehicle,
                      stage: StageMapper.mapOrderItemStage(item.stage),
                      rejectedNote: null,
                      onTap: () => controller.openOrderItem(order, item),
                    ));
                  }).toList(),
                ),
              ),
              // Shimmer skeleton while fetching more
              Obx(() {
                final load = controller.ordersRepository?.isFetchingMore.value ?? false;
                if (load) {
                  return Column(
                    children: List.generate(2, (_) => const PlaceHolderRequestCard()),
                  );
                }
                return SizedBox();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInspectionsList(BuildContext context) {
    final list = controller.individualInspections;

    if (list.isEmpty) {
      return _EmptyOrdersState(
        message: 'No individual requests'.tr,
        onRefresh: controller.refreshPage,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: controller.refreshPage,
          color: FColors.primaryColor,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: controller.scrollController,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: list
                      .map((item) => InspectionCard(
                            slug: item.slug,
                            customerName: item.customer?.name,
                            vehicle: item.vehicle,
                            stage: item.stage,
                            rejectedNote: item.rejectedNote,
                            onTap: () => controller.openInspection(item),
                          ))
                      .toList(),
                ),
              ),
              // Shimmer skeleton while fetching more
              Obx(() {
                final load =
                    controller.repository?.isFetchingMore.value ?? false;
                if (load) {
                  return Column(
                    children: List.generate(2, (_) => const PlaceHolderRequestCard()),
                  );
                }
                return SizedBox();
              }),
            ],
          ),
        );
      },
    );
  }
}

/// Professional empty-state widget shown when a tab has no orders.
class _EmptyOrdersState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRefresh;
  const _EmptyOrdersState({required this.message, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: FColors.primaryColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.document,
                        size: 64,
                        color: FColors.darkGrey.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: FSizes.md),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: FColors.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      Text(
                        'Pull down to refresh'.tr,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FColors.darkGrey.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shimmer skeleton that matches the CompanyCard shape
class _CompanyCardSkeleton extends StatelessWidget {
  const _CompanyCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return Card(
      color: isDark ? FColors.black : FColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FSizes.md),
        child: Row(
          children: [
            // Circle avatar placeholder
            CircleSkeleton(size: 48),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 140, height: 14, color: FColors.grey),
                  const SizedBox(height: 8),
                  Skeleton(width: 90, height: 12, color: FColors.grey),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Skeleton(width: 70, height: 10, color: Colors.green.withValues(alpha: 0.3)),
                      const SizedBox(width: 6),
                      Skeleton(width: 80, height: 10, color: Colors.orange.withValues(alpha: 0.3)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
