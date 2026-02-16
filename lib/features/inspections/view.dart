import 'package:fahis_inspector/features/inspections/components/company_card.dart';
import 'package:fahis_inspector/features/inspections/components/company_inspections_screen.dart';
import 'package:fahis_inspector/features/inspections/components/inspection_card.dart';
import 'package:fahis_inspector/features/inspections/components/no_more_inspections.dart';
import 'package:fahis_inspector/features/inspections/components/on_loading_inspections.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/features/inspections/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

          // Show empty state if no data at all
          if (controller.inspections.isEmpty) return NotMoreInspections();

          // Show segments only when stage=All and no search active
          // Otherwise show flat list (search results or stage-filtered)
          return Obx(() {
            final isDefault = controller.selectedStage.value == InspectionStage.all
                && !controller.isSearchActive.value;

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
    return Obx(() {
      final selected = controller.selectedSegment.value;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: FColors.grey.withValues(alpha: 0.5),
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

/// Displays grouped companies with request counts
class _CompanyList extends StatelessWidget {
  final InspectionsController controller;
  const _CompanyList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final groups = controller.companyGroups;

    if (groups.isEmpty) {
      return Center(
        child: Text(
          'No company requests'.tr,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: FColors.darkGrey),
        ),
      );
    }

    final entries = groups.entries.toList();

    return RefreshIndicator(
      onRefresh: controller.refreshPage,
      color: FColors.primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return CompanyCard(
            companyName: entry.key,
            inspections: entry.value,
            onTap: () => Get.to(
              () => CompanyInspectionsScreen(
                companyName: entry.key,
                inspections: entry.value,
              ),
            ),
          );
        },
      ),
    );
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
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: FColors.darkGrey),
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
          return InspectionCard(inspection: list[index]);
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
    final list = controller.individualInspections;

    if (list.isEmpty) {
      return Center(
        child: Text(
          'No individual requests'.tr,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: FColors.darkGrey),
        ),
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
                      .map((item) => InspectionCard(inspection: item))
                      .toList(),
                ),
              ),
              // Pagination loading indicator
              Obx(() {
                final load =
                    controller.repository?.isFetchingMore.value ?? false;
                if (load) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  return SizedBox();
                }
              }),
            ],
          ),
        );
      },
    );
  }
}
