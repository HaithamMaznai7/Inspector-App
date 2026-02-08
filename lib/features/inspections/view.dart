import 'package:fahis_inspector/features/inspections/components/inspection_card.dart';
import 'package:fahis_inspector/features/inspections/components/no_more_inspections.dart';
import 'package:fahis_inspector/features/inspections/components/on_loading_inspections.dart';
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
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
      ),
      child: GetBuilder<InspectionsController>(
        init: InspectionsBinding().instance,
        builder: (controller) {
        final list = controller.inspections;
        final isLoad = controller.isLoading.value;

        if (isLoad) {
          return OnLoadingInspections();
        }

        if (list.isEmpty) {
          return NotMoreInspections();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: controller.refreshPage,
              semanticsLabel: 'hh',
              color: FColors.primaryColor,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: controller.scrollController,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: list
                          .map((item) => InspectionCard(inspection: item))
                          .toList(),
                    ),
                  ),
                  // ...list.map((item) => InspectionCard(inspection: item)).toList(),
                  Obx(() {
                    final load = controller.repository.isFetchingMore.value;
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
      }),
    );
  }
}
