import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
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

        // Get OBD codes from controller's box
        final obdData = c.box?.get('Inspection_Obd');
        final obdCodes = obdData != null
            ? (obdData as List)
                  .map(
                    (item) => OBDCode.fromJson(
                      Map<String, dynamic>.from(item as Map),
                    ),
                  )
                  .toList()
            : <OBDCode>[];

        return InfoCard(
          title: Text('Inspection OBD Codes'),
          tilePadding: FSizes.md,
          icon: Iconsax.setting_2,
          children: [
            if (obdCodes.isEmpty)
              Padding(
                padding: EdgeInsets.all(FSizes.md),
                child: Text(
                  InspectionPage.notYet.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.apply(color: FColors.grey),
                ),
              )
            else
              ...obdCodes.map((code) {
                return ListTile(
                  leading: Icon(Iconsax.code, color: FColors.primaryColor),
                  title: Text(code.code),
                  subtitle: Text(code.description),
                );
              }),
          ],
        );
      },
    );
  }
}
