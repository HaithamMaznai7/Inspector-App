
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/enums.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestStatusBottomSheet extends StatelessWidget {

  const RequestStatusBottomSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      child: SingleChildScrollView(
        child: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => Get.back(result: PointStatus.good),
                  child: SizedBox(
                    height: 60,
                    child: Card(
                      color: FColors.success,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.transparent.withOpacity(0),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(FTexts.good.tr, style: Theme.of(context).textTheme.headlineMedium,),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FSizes.spaceBtwItems),
                InkWell(
                  onTap: () => Get.back(result: PointStatus.note),
                  child: SizedBox(
                    height: 60,
                    child: Card(
                      color: FColors.warning,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.transparent.withOpacity(0),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(FTexts.notes.tr, style: Theme.of(context).textTheme.headlineMedium,),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FSizes.spaceBtwItems),
                InkWell(
                  onTap: () => Get.back(result: PointStatus.none),
                  child: SizedBox(
                    height: 60,
                    child: Card(
                      color: FColors.darkGrey.withOpacity(.4),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.transparent.withOpacity(0),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(FTexts.na.tr, style: Theme.of(context).textTheme.headlineMedium,),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FSizes.spaceBtwItems),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
