import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InspectionPhotosReview extends StatelessWidget {
  const InspectionPhotosReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
      color: FColors.grey,
      child: GetBuilder<InspectionDetailsController>(
        init: InspectionDetailsBinding().instance,
        builder: (c) {
          final vehicleDetailsLoading = c.vehicleDetailsLoading.value;
          final hasPhotos = c.inspection.value?.hasPhotos;
          if (hasPhotos == null || vehicleDetailsLoading) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.lg,
              ),
              child: Center(
                child: CircularProgressIndicator(color: FColors.primaryColor),
              ),
            );
          }
          if (!hasPhotos) {
            return SizedBox();
          }

          return ExpansionTile(
            title: Text('Inspection Photos'),
            childrenPadding: EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.lg,
            ),
            internalAddSemanticForOnTap: true,
            leading: TextButton(
              onPressed: () {},
              child: Text(
                'Edit',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(color: FColors.warning),
              ),
            ),
            children: initializeInfo(context, {
              DetailsPage.vin.tr: c.vehicleDetails.value?.vin,
              DetailsPage.plateNumber.tr: c.vehicleDetails.value?.plate,
              DetailsPage.yearModel.tr: c.vehicleDetails.value?.yearModel,
              DetailsPage.drivetrain.tr: c.vehicleDetails.value?.drivetrain,
              DetailsPage.bodyType.tr: c.vehicleDetails.value?.bodyType,
              DetailsPage.fuelType.tr: c.vehicleDetails.value?.fuelType,
              DetailsPage.gasolineType.tr: c.vehicleDetails.value?.gasolineType,
              DetailsPage.gearboxType.tr: c.vehicleDetails.value?.gearbox,
              DetailsPage.cylindersNo.tr: c.vehicleDetails.value?.cylindersNo,
              DetailsPage.engineSize.tr: c.vehicleDetails.value?.enginSize,
              DetailsPage.seatNo.tr: c.vehicleDetails.value?.seatsNo,
              DetailsPage.seatType.tr: c.vehicleDetails.value?.seatsType,
              DetailsPage.milage.tr: c.vehicleDetails.value?.milage,
              DetailsPage.exteriorColor.tr: c.vehicleDetails.value?.color,
              DetailsPage.interiorColor.tr: c.vehicleDetails.value?.seatColor,
            }).toList(),
          );
        },
      ),
    );
  }

  List<Widget> initializeInfo(BuildContext context, Map<String, dynamic> data) {
    final List<Widget> rows = [];
    List<Widget> rowChildren = [];

    int index = 0;

    data.forEach((key, value) {
      rowChildren.add(
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(text: '$key: '),
                TextSpan(
                  text: value?.toString() ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );

      index++;

      if (rowChildren.length == 3 || index == data.length) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: FSizes.sm),
            child: Row(children: rowChildren),
          ),
        );
        rowChildren = [];
      }
    });

    return rows;
  }
}
