import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection/screens/widgets/center_section.dart';
import 'package:fahis_inspector/features/inspection/screens/widgets/inspection_info.dart';
import 'package:fahis_inspector/features/inspection/screens/widgets/reviewer_note_section.dart';
import 'package:fahis_inspector/features/inspection/screens/widgets/vehicle_info.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverView extends StatelessWidget {
  const OverView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = InspectionController.instance;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            GetBuilder<InspectionController>(
              init: Get.find<InspectionController>(),
              builder: (c) {
                if (c.inspection.value?.note != null) {
                  return ReviewerNoteSection(
                    title: DetailsPage.reviewNoteTitle.tr,
                    note: c.inspection.value?.note,
                    color: FColors.warning,
                  );
                }

                return SizedBox();
              },
            ),
            GetBuilder<InspectionController>(
              init: Get.find<InspectionController>(),
              builder: (c) {
                if (c.inspection.value?.rejectedNote != null) {
                  return ReviewerNoteSection(
                    title: DetailsPage.reviewNoteTitle.tr,
                    note: c.inspection.value?.rejectedNote,
                    color: FColors.error,
                  );
                }

                return SizedBox();
              },
            ),
            const InspectionInfo(),
            const VehicleInfo(),
            CenterSection(),
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: FHelper.screenWidth() * .9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Obx(() {
              final stage = controller.inspection.value!.stage.cancel;
              if (stage != null) {
                return Expanded(
                  // width: double.infinity,
                  child: ElevatedButton(
                    style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                      backgroundColor: MaterialStateProperty.all(FColors.darkGrey),
                    ),
                    onPressed: () => controller.setSatge(stage),
                    child: Text(stage.getLabel),
                  ),
                );
              }

              return SizedBox();
            }),

            Obx(() {
              final next = controller.inspection.value!.stage.next;
              final reject = controller.inspection.value!.stage.next;

              return SizedBox(
                width: next != null && reject != null ? FSizes.spaceBtwInputFields : 0,
              );
            }),

            Obx(() {
              final stage = controller.inspection.value!.stage.next;

              if (stage != null) {
                return Expanded(
                  // width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.setSatge(stage),
                    child: Text(stage.getLabel),
                  ),
                );
              }
              return SizedBox();
            }),
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }
}
