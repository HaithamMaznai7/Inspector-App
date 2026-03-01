import 'package:fahis_inspector/common/widgets/skeletons/skeleton.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class RequestDetailsOnLoading extends StatelessWidget {
  const RequestDetailsOnLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return Column(
      children: [
        // Add a padding to the top
        Card(
          color: isDark ? FColors.darkGrey.withValues(alpha: .2) : FColors.grey,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: FSizes.lg, horizontal: FSizes.md),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DetailsPage.vehicleInfoTile.tr,
                          style:Theme.of(context).textTheme.titleLarge
                      ),
                      const Skeleton(width: 80, height: 10, color: FColors.darkGrey)
                    ],
                  ),
                  const SizedBox(height: FSizes.spaceBtwSections),
                  const Row(
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Icon(Iconsax.user),
                            SizedBox(width: FSizes.sm,),
                            Skeleton(width: 120, height: 15, color: FColors.darkGrey)
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          children: [
                            Icon(Iconsax.call),
                            SizedBox(width: FSizes.sm,),
                            Skeleton(width: 120, height: 15, color: FColors.darkGrey)
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),
                  const Row(
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Icon(Iconsax.category),
                            SizedBox(width: FSizes.sm,),
                            Skeleton(width: 120, height: 15, color: FColors.darkGrey)
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          children: [
                            Icon(Iconsax.status),
                            SizedBox(width: FSizes.sm,),
                            Skeleton(width: 120, height: 15, color: FColors.darkGrey)
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),
                  const Row(
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Icon(Icons.brightness_auto),
                            SizedBox(width: FSizes.sm,),
                            Skeleton(width: 120, height: 15, color: FColors.darkGrey)
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          children: [
                            // RowText(icon: Icons.model_training,title: 'Model'.tr,value: (controller.inspectionReq.vehicleModel?.name)),

                            Icon(Icons.model_training),
                            SizedBox(width: FSizes.sm,),
                            Skeleton(width: 120, height: 15, color: FColors.darkGrey)
                          ],
                        ),
                      ),                        ],
                  ),
                ],
              )
          ),
        ),
        const SizedBox(height: FSizes.spaceBtwSections,),
        const Skeleton(width: double.infinity, height: 60, color: FColors.darkGrey),
        const SizedBox(height: FSizes.spaceBtwItems,),
        const Skeleton(width: double.infinity, height: 60, color: FColors.darkGrey),
        const SizedBox(height: FSizes.spaceBtwItems,),
        const Skeleton(width: double.infinity, height: 60, color: FColors.darkGrey),
        const SizedBox(height: FSizes.spaceBtwItems,),
        const Skeleton(width: double.infinity, height: 60, color: FColors.darkGrey),
        const SizedBox(height: FSizes.spaceBtwItems,),
        const Skeleton(width: double.infinity, height: 60, color: FColors.darkGrey),
        const SizedBox(height: FSizes.spaceBtwItems,),
        const Skeleton(width: double.infinity, height: 60, color: FColors.darkGrey),
        const SizedBox(height: FSizes.spaceBtwItems,),
        const Skeleton(width: double.infinity, height: 60, color: FColors.darkGrey),
      ],
    );
  }
}