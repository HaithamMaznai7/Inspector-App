import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionInfoReview extends StatelessWidget {
  const InspectionInfoReview({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionDetailsController>(
      init: InspectionDetailsBinding().instance,
      builder: (c) {
        final isLoading = c.isLoading.value;
        final inspection = c.inspection.value;

        if (inspection == null || isLoading) {
          return SizedBox();
        }
        
        // if (!hasDetails) {
        //   return Card(
        //     margin: EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
        //     color: FColors.grey,
        //     child: Padding(
        //       padding: EdgeInsets.symmetric(
        //         horizontal: FSizes.md,
        //         vertical: FSizes.lg,
        //       ),
        //       child: Center(
        //         child: Text('This Inspection Is Not Contain Vehicle Details'),
        //       ),
        //     )
        //   );
        // }

        return InfoCard.fromMap(
          title: Text(InspectionPage.generalInfo.tr),
          tilePadding: FSizes.md,
          icon: Iconsax.info_circle,
          subtitle: Align(
            alignment: AlignmentGeometry.centerRight,
            child: TextButton(
              onPressed: () => Helpers.copy('${c.slug}'),
              child: Text(
                '#${inspection.slug}',
                style: Theme.of(context).textTheme.labelMedium,
                locale: Get.locale,
                textAlign: TextAlign.start,
              ),
            ),
          ),
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: FSizes.sm),
            decoration: BoxDecoration(
              color: c.inspection.value?.stage.color.withOpacity(.1),
              borderRadius: BorderRadius.circular(FSizes.sm),
            ),
            child: Text(
              inspection.stage.label,
              style: Theme.of(context).textTheme.bodyLarge?.apply(
                color: inspection.stage.color,
              ),
            ),
          ),
          items: {
            InspectionPage.inspectionType.tr: "${inspection.inspectionType?.title} (${inspection.inspectionType?.description})",
            InspectionPage.center.tr: inspection.center?.center.label ?? InspectionPage.notYet.tr,
            InspectionPage.centerBranch.tr: inspection.center?.branch?.label ?? InspectionPage.notYet.tr,
            InspectionPage.city.tr: inspection.center?.city?.label ?? InspectionPage.notYet.tr,
            InspectionPage.bookingDate.tr: inspection.center?.datetime.toString() ?? InspectionPage.notYet.tr,
            InspectionPage.assignedTo.tr: inspection.assignedTo?.label ?? InspectionPage.anyInspector.tr,
            InspectionPage.inspector.tr: inspection.inspector?.label ?? InspectionPage.notYet.tr,
            InspectionPage.inspectedAt.tr: inspection.inspectedAt?.toString() ?? InspectionPage.notYet.tr,
            InspectionPage.reviewedAt.tr: inspection.reviewedAt?.toString() ?? InspectionPage.notYet.tr,
            InspectionPage.createdAt.tr: inspection.createdDate.toString(),
          },
        );
      },
    );
  }
}
