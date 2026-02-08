import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/review_point.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionPointsReview extends StatelessWidget {
  const InspectionPointsReview({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionDetailsController>(
      init: InspectionDetailsBinding().instance,
      builder: (c) {
        final isLoading = c.isLoading.value;
        final inspection = c.inspection.value;
        final points = ReviewPoint.set(c.inspectionPoints.value);

        if (inspection == null || isLoading) {
          return SizedBox();
        }

        return InfoCard(
          title: Text(InspectionPage.inspectionPointReview.tr),
          icon: Iconsax.check,
          tilePadding: FSizes.md,
          children: [
            ...points.cats.map((cat) {
              return InfoCard(
                title: Text(cat.category.title),
                subtitle: Text('Note: ${cat.note}, N/A: ${cat.none}'),
                leading: Container(
                  padding: EdgeInsets.symmetric(horizontal: FSizes.sm),
                  decoration: BoxDecoration(
                    color: FColors.success.withOpacity(.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "${cat.good}/${cat.points.length}",
                    style: Theme.of(context).textTheme.bodyLarge?.apply(
                      color: FColors.success,
                    ),
                  ),
                ),
                children: [
                  ...cat.points.map((point) {
                    return ListTile(
                      title: Text(point.title),
                      subtitle: Text(point.description),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: FSizes.sm),
                        decoration: BoxDecoration(
                          color: c.inspection.value?.stage.color.withOpacity(.1),
                          borderRadius: BorderRadius.circular(FSizes.sm),
                        ),
                        child: Text(
                          point.status.name,
                          style: Theme.of(context).textTheme.bodyLarge?.apply(
                            color: point.status.color(),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
