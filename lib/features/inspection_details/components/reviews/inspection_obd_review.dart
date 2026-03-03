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

        // WHAT: Read OBD codes from Hive cache and deserialize safely.
        // WHY: The OBD data is stored in `box` (Inspection_$slug box) with
        //      key = slug. Hive stores maps as Map<dynamic, dynamic>, so
        //      each item must be cast before parsing. Per-item try/catch
        //      ensures one corrupted entry doesn't blank the entire card.
        // EDGE CASES:
        //   - obdData is null → empty list (shows "not yet" message)
        //   - One corrupted entry → skipped, others still display
        final obdData = c.assetsBox?.get(c.slug);
        final List<OBDCode> obdCodes = [];
        if (obdData != null) {
          for (final item in obdData) {
            try {
              obdCodes.add(
                OBDCode.fromJson(Map<String, dynamic>.from(item as Map)),
              );
            } catch (e) {
              debugPrint('Error parsing OBD code in review: $e');
            }
          }
        }

        return InfoCard(
          title: Text(InspectionPage.inspectionOBDCodes.tr),
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
