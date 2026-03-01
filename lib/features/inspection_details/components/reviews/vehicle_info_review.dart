import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VehicleInfoReview extends StatelessWidget {
  const VehicleInfoReview({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionDetailsController>(
      init: InspectionDetailsBinding().instance,
      builder: (c) {
        final isLoading = c.isLoading.value;
        final vehicle = c.inspection.value?.vehicle;

        if (vehicle == null || isLoading) {
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
          title: Text(InspectionPage.vehicleInfo.tr),
          icon: Iconsax.car,
          tilePadding: FSizes.md,
          trailing: vehicle.plate != null 
          ? Container(
            padding: EdgeInsets.symmetric(horizontal: FSizes.sm),
            decoration: BoxDecoration(
              color: c.inspection.value?.stage.color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(FSizes.sm),
            ),
            child: Text(
              vehicle.plate!,
              style: Theme.of(context).textTheme.bodyLarge?.apply(
                color: FColors.success,
              ),
            ),
          )
          : null,
          items: {
            InspectionPage.vin.tr: vehicle.vin,
            InspectionPage.serialNo.tr: vehicle.serialNo,
            InspectionPage.make.tr: vehicle.make?.label,
            InspectionPage.model.tr: vehicle.model?.label,
            InspectionPage.storageSize.tr: vehicle.storageSize,
            InspectionPage.vehicleShape.tr: vehicle.vehicleShape,
            InspectionPage.yearModel.tr: vehicle.year,
            InspectionPage.plate.tr: vehicle.plate,
          },
        );
      },
    );
  }
}
