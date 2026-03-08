import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/features/inspection_details/components/inspector_note_section.dart';
import 'package:fahis_inspector/features/inspection_details/components/reviewer_note_section.dart';
import 'package:fahis_inspector/features/inspection_details/components/reviews/inspection_body_notes_review.dart';
import 'package:fahis_inspector/features/inspection_details/components/reviews/inspection_info_review.dart';
import 'package:fahis_inspector/features/inspection_details/components/reviews/inspection_obd_review.dart';
import 'package:fahis_inspector/features/inspection_details/components/reviews/inspection_photos_review.dart';
import 'package:fahis_inspector/features/inspection_details/components/reviews/inspection_points_review.dart';
import 'package:fahis_inspector/features/inspection_details/components/stage_selector.dart';
import 'package:fahis_inspector/features/inspection_details/components/reviews/vehicle_info_review.dart';
import 'package:fahis_inspector/features/inspection_details/components/connect_person_info.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InspectionDetailsScreen extends StatelessWidget {
  const InspectionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = InspectionDetailsBinding().instance;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: FColors.primaryGradient),
        ),
        title: Text(
          DetailsPage.pageTitle.trParams({'inspection': controller.slug ?? ''}),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.apply(color: FColors.white),
        ),
        // centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => controller.share(),
            icon: Icon(Icons.share, color: FColors.white),
          ),
        ],
        leading: BackPageButton(color: FColors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: FColors.primaryColor),
                SizedBox(height: FSizes.md),
                Text(
                  InspectionPage.loadingInspectionDetails.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.apply(color: FColors.darkGrey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              controller.load(controller.slug!, refresh: true),
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          child: Container(
            color: FColors.grey.withValues(alpha: 0.05),
            child: ListView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.only(top: FSizes.sm, bottom: FSizes.xl),
              children: [
                InspectorNoteSection(),
                ReviewerNoteSection(),
                // Always show general info and contact
                const InspectionInfoReview(),
                // Only show cards for steps that exist in this order
                if (controller.inspection.value?.hasDetails ?? false)
                  const VehicleInfoReview(),
                const ConnectPersonInfo(),
                if (controller.inspection.value?.hasPoints ?? false)
                  const InspectionPointsReview(),
                if (controller.inspection.value?.hasPhotos ?? false)
                  const InspectionPhotosReview(),
                if (controller.inspection.value?.hasBody ?? false)
                  const InspectionBodyNotesReview(),
                if (controller.inspection.value?.hasObd ?? false)
                  const InspectionOBDReview(),
                SizedBox(height: FSizes.md),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: StageSelector(),
    );
  }
}
