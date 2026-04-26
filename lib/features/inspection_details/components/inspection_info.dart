import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/util/helpers/cached_image_key.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/formatters/formatter.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionInfo extends StatelessWidget {
  const InspectionInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
      color: FColors.grey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.lg,
        ),
        child: GetBuilder<InspectionDetailsController>(
          init: InspectionDetailsBinding().instance,
          builder: (c) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Helpers.copy('${c.slug}'),
                      icon: Icon(Iconsax.copy, weight: 30),
                    ),
                    Text(
                      '#${c.slug}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: FSizes.sm),
                      decoration: BoxDecoration(
                        color: c.inspection.value?.stage.color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(FSizes.sm),
                      ),
                      child: Text(
                        c.inspection.value?.stage.label ?? 'Undefined',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.apply(
                          color: c.inspection.value?.stage.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.sm),
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Row(
                        children: [
                          c.inspection.value?.vehicle?.make?.avatar != null
                              ? CachedNetworkImage(
                                  imageUrl: c.inspection.value!.vehicle!.make!.avatar!,
                                  cacheKey: stableCacheKey(c.inspection.value!.vehicle!.make!.avatar!),
                                  fit: BoxFit.contain,
                                  width: FSizes.iconInlineMd,
                                  height: FSizes.iconInlineMd,
                                  placeholder: (_, _) => SizedBox(width: FSizes.iconInlineMd, height: FSizes.iconInlineMd),
                                  errorWidget: (_, _, _) => SizedBox(width: FSizes.iconInlineMd, height: FSizes.iconInlineMd),
                                )
                              : SizedBox(),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: Text(
                              '${c.inspection.value?.vehicle?.make?.label} - ${c.inspection.value?.vehicle?.model?.label} - ${c.inspection.value?.vehicle?.year}',
                              style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.spaceBtwItems),
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Row(
                        children: [
                          const Icon(Iconsax.category),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: Text.rich(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              TextSpan(
                                text:
                                    '${c.inspection.value?.inspectionType?.title} ',
                                style: Theme.of(context).textTheme.bodyLarge,
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        '(${c.inspection.value?.inspectionType?.description}) ',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.spaceBtwItems),
                Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: Row(
                        children: [
                          const Icon(Iconsax.note),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: Text(
                              c.inspection.value != null
                                  ? EFormatter.getDateFormat.format(
                                      c.inspection.value!.createdDate,
                                    )
                                  : '',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
