import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/review_point.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
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
        final points = ReviewPoint.set(c.inspectionPoints);

        if (inspection == null || isLoading) {
          return SizedBox();
        }

        return InfoCard(
          title: Text(InspectionPage.inspectionPointReview.tr),
          icon: Iconsax.check,
          tilePadding: FSizes.md,
          children: [
            ...points.cats.map((cat) {
              return Padding(
                padding: EdgeInsets.only(bottom: FSizes.xs),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: FColors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  child: InfoCard(
                    title: Text(cat.category.title),
                    subtitle: Text(
                      '${FTexts.notes.tr}: ${cat.note}, ${FTexts.na.tr}: ${cat.none}',
                    ),
                    initiallyExpanded: false,
                    showCard: false,
                    leading: Container(
                      padding: EdgeInsets.symmetric(horizontal: FSizes.sm),
                      decoration: BoxDecoration(
                        color: FColors.success.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        "${cat.good}/${cat.points.length}",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.apply(color: FColors.success),
                      ),
                    ),
                    children: [
                      ...cat.points.map((point) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(point.title),
                              subtitle: Text(point.description),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: FSizes.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: c.inspection.value?.stage.color
                                      .withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(
                                    FSizes.sm,
                                  ),
                                ),
                                child: Text(
                                  point.status.name,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.apply(color: point.status.color()),
                                ),
                              ),
                            ),
                            if (point.image != null)
                              Container(
                                height: FSizes.imagePreviewSm,
                                margin: EdgeInsets.only(
                                  left: FSizes.md,
                                  right: FSizes.md,
                                  bottom: FSizes.sm,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    FSizes.borderRadiusMd,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: InteractiveViewer(
                                            child: Image.network(
                                              point.image!,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Image.network(
                                      point.image!,
                                      height: FSizes.imagePreviewSm,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            if (point.note != null && point.note!.isNotEmpty)
                              Container(
                                margin: EdgeInsets.only(
                                  left: FSizes.md,
                                  right: FSizes.md,
                                  bottom: FSizes.sm,
                                ),
                                padding: EdgeInsets.all(FSizes.sm),
                                decoration: BoxDecoration(
                                  color: FColors.grey.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(
                                    FSizes.borderRadiusSm,
                                  ),
                                  border: Border.all(
                                    color: FColors.grey.withValues(alpha: .3),
                                  ),
                                ),
                                child: Text(
                                  point.note!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
