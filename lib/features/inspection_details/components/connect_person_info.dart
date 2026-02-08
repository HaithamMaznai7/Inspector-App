import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ConnectPersonInfo extends StatelessWidget {
  const ConnectPersonInfo({super.key});

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
      
        return InfoCard.fromMap(
          title: Text(InspectionPage.connectPersonInfo.tr),
          tilePadding: FSizes.md,
          icon: Iconsax.personalcard,
          subtitle: Align(
            alignment: AlignmentGeometry.centerRight,
            child: TextButton(
              onPressed: () => Helpers.copy('${inspection.customer?.phone}'),
              child: Text(
                '${inspection.customer?.phone}',
                style: Theme.of(context).textTheme.labelMedium,
                locale: Get.locale,
                textAlign: TextAlign.start,
              ),
            ),
          ),
          trailing: inspection.customer?.phone != null 
          ? IconButton(
            color: FColors.success,
            icon: Icon(Iconsax.call),
            onPressed: () async => await Helpers.callTo(mobile: inspection.customer!.phone!),
          )
          : Icon(Iconsax.call, color: FColors.grey),
          items: {
            InspectionPage.inspectionType.tr: "${inspection.inspectionType?.title} (${inspection.inspectionType?.description})",
            InspectionPage.center.tr: inspection.center?.center.label ?? 'No Booking',
            InspectionPage.centerBranch.tr: inspection.center?.branch?.label ?? 'No Branch',
            InspectionPage.city.tr: inspection.center?.city?.label ?? 'No City',
            InspectionPage.bookingDate.tr: inspection.center?.datetime.toString() ?? 'Not Yet',
            InspectionPage.assignedTo.tr: inspection.assignedTo?.label ?? 'Any',
            InspectionPage.inspector.tr: inspection.inspector?.label ?? 'No Inspector Yet',
            InspectionPage.inspectedAt.tr: inspection.inspectedAt?.toString() ?? 'Not Yet',
            InspectionPage.reviewedAt.tr: inspection.reviewedAt?.toString() ?? 'Not Yet',
            InspectionPage.createdAt.tr: inspection.createdDate.toString(),
          },
        );
      },
    );
  }
}
