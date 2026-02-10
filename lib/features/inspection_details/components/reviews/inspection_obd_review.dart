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

class InspectionOBDReview extends StatelessWidget {
  const InspectionOBDReview({super.key});

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
                  onPressed: () async =>
                      await Helpers.callTo(mobile: inspection.customer!.phone!),
                )
              : Icon(Iconsax.call, color: FColors.grey),
          items: {
            InspectionPage.contactName.tr:
                inspection.customer?.name ?? InspectionPage.notYet.tr,
            InspectionPage.contactEmail.tr:
                inspection.customer?.email ?? InspectionPage.notYet.tr,
            InspectionPage.contactPhone.tr:
                inspection.customer?.phone ?? InspectionPage.notYet.tr,
            InspectionPage.contactCity.tr:
                inspection.customer?.city?.label ?? InspectionPage.notYet.tr,
          },
        );
      },
    );
  }
}
