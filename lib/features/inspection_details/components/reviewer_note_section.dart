import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewerNoteSection extends StatelessWidget {
  const ReviewerNoteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionDetailsController>(
      init: InspectionDetailsBinding().instance,
      builder: (c) {
        final note = c.inspection.value?.note;
        if (note != null && note.isNotEmpty && note != '') {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FColors.warning.withOpacity(.7),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              border: Border.all(width: 2, color: FColors.warning),
            ),
            padding: EdgeInsets.symmetric(
              vertical: FSizes.md,
              horizontal: FSizes.lg,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: FSizes.sm,
              vertical: FSizes.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DetailsPage.reviewNoteTitle.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: FColors.white),
                ),
                const SizedBox(height: FSizes.spaceBtwItems),
                Text(
                  note!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: FColors.white),
                ),
              ],
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
