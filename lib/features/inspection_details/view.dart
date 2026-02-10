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
      body: RefreshIndicator(
        onRefresh: () async => controller.load(controller.slug!),
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        child: Container(
          color: FColors.grey.withOpacity(0.05),
          child: ListView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(top: FSizes.sm, bottom: FSizes.xl),
            children: [
              InspectorNoteSection(),
              ReviewerNoteSection(),
              const InspectionInfoReview(),
              const VehicleInfoReview(),
              const ConnectPersonInfo(),
              const InspectionPointsReview(),
              const InspectionPhotosReview(),
              //const InspectionBodyNotesReview(),
              const InspectionOBDReview(),
              SizedBox(height: FSizes.md),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StageSelector(),
    );
  }
}
