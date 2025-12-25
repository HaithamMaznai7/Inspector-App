import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewerNoteSection extends StatelessWidget {
  final controller = Get.find<InspectionController>();
  final String? note;
  final String title;
  final Color color;
  ReviewerNoteSection({super.key, required this.title, this.note, this.color = FColors.warning});

  @override
  Widget build(BuildContext context) {
    // final controller = RequestDetailsController.instance;
    if(note != null && note!.isNotEmpty && note != ''){

      return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: color.withOpacity(.7),
                  borderRadius: BorderRadius.circular(
                      FSizes.borderRadiusMd),
                  border: Border.all(width: 2, color: color)
              ),
              padding: EdgeInsets.symmetric(
                  vertical: FSizes.md, horizontal: FSizes.lg),
              margin: EdgeInsets.symmetric(
                  horizontal: FSizes.sm, vertical: FSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: FColors.white,
                  )),
                  const SizedBox(height: FSizes.spaceBtwItems),
                  Text(note!, style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: FColors.white,
                  )),
                ],
              )
          );

    }else{

      return SizedBox();
    }

  }
}
