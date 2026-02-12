import 'package:fahis_inspector/features/inspection_points/components/card.dart';
import 'package:fahis_inspector/features/inspection_points/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:get/get.dart';

/// Editing screen for a single category's inspection points.
/// The user navigates here from [InspectionPointResults] by tapping
/// a specific category card. Only that category's points are shown.
/// Press "Done" or the back arrow to return and refresh the results.
class InspectionPointsScreen extends StatelessWidget {
  const InspectionPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Show the selected category title in the AppBar
        title: GetBuilder<InspectionPointsController>(
          init: InspectionPointsBinding().instance,
          builder: (controller) {
            final category = controller.category.value;
            return Text(
              category?.category.title ?? InspectionPage.inspectionDetailsTitle.tr,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: FColors.white,
              ),
            );
          },
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: FColors.primaryGradient),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        // "Done" button — pops back to the results page
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: FSizes.sm),
            child: TextButton(
              onPressed: () => Get.back(),
              child: Text(
                InspectionPage.doneBtn.tr,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      // Point cards list for the selected category only
      body: GetBuilder<InspectionPointsController>(
        init: InspectionPointsBinding().instance,
        builder: (controller) {
          final category = controller.category.value;

          if (category == null) {
            return Center(
              child: CircularProgressIndicator(color: FColors.primaryColor),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(FSizes.md),
            itemCount: category.points.length,
            itemBuilder: (context, index) {
              final point = category.points[index];
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
      ),
    );
  }
}
