import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectorNoteSection extends StatelessWidget {
  const InspectorNoteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionDetailsController>(
      init: InspectionDetailsBinding().instance,
      builder: (c) {
        final note = c.inspection.value?.rejectedNote;
        if (note != null && note.isNotEmpty && note != '') {
          return InfoCard(
            title: Text(DetailsPage.reviewNoteTitle.tr),
            tilePadding: FSizes.md,
            icon: Iconsax.note_2,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.sm,
                ),
                child: Text(
                  note,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
