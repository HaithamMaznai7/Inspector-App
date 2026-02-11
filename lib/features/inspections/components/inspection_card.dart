import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/models/vehicle.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:get/get.dart';

class InspectionCard extends StatelessWidget {
  const InspectionCard({super.key, required this.inspection});

  final Inspection inspection;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return InkWell(
      child: SizedBox(
        width: double.infinity,
        child: Card(
          color: FHelper.isDarkMode(Get.context!)
              ? FColors.black
              : FColors.white,
          child: Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(inspection.stage.icon, color: inspection.stage.color),
                const SizedBox(width: FSizes.spaceBtwItems),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        this.inspection.customer?.name ?? '---',
                        style: Theme.of(context).textTheme.titleMedium?.apply(
                          color: isDark
                              ? FColors.white.withOpacity(.8)
                              : FColors.dark,
                        ),
                      ),

                      const SizedBox(height: FSizes.sm),

                      Text(
                        '${inspection.vehicle?.make?.label ?? ''} - ${inspection.vehicle?.model?.label ?? ''} - ${inspection.vehicle?.year ?? ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.apply(
                          color: isDark
                              ? FColors.white.withOpacity(.8)
                              : FColors.dark,
                        ),
                      ),

                      const SizedBox(height: FSizes.sm),

                      Row(
                        children: [
                          inspection.vehicle?.make?.avatar != null
                              ? Image.network(
                                  inspection.vehicle!.make!.avatar!,
                                  fit: BoxFit.contain,
                                  width: 30,
                                  height: 30,
                                )
                              : SizedBox(),
                          const SizedBox(width: FSizes.sm),
                          Text(
                            inspection.vehicle?.plate ?? '',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.apply(color: FColors.primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: FSizes.spaceBtwItems),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '#${inspection.slug}',
                      style: Theme.of(context).textTheme.labelMedium?.apply(
                        color: isDark ? FColors.grey : FColors.darkerGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: FSizes.spaceBtwItems),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: FSizes.sm),
                      decoration: BoxDecoration(
                        color: inspection.stage.color.withOpacity(.1),
                        borderRadius: BorderRadius.circular(FSizes.sm),
                      ),
                      child: Text(
                        inspection.stage.label,
                        style: Theme.of(context).textTheme.bodyLarge?.apply(
                          color: inspection.stage.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () => InspectionsBinding().instance.openInspection(inspection),
    );
  }
}

class VehicleRow extends StatelessWidget {
  const VehicleRow({super.key, required this.vehicle});

  final Vehicle vehicle;

  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // FImage(
        //   image: vehicle.make?.image,
        //   placeHolder: Image.asset(FImages.appIcon) ,
        //   height: 30,
        //   width: 30,
        // ),
        Text(
          vehicle.make?.label ?? '',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.apply(
            color: isDark ? FColors.white.withOpacity(.8) : FColors.dark,
          ),
        ),

        // Text(
        //   vehicle.model?.label ?? '',
        //   overflow: TextOverflow.ellipsis,
        //   style: Theme.of(context).textTheme.titleLarge?.apply(
        //       color: isDark ? FColors.white.withOpacity(.8) : FColors.dark
        //   ),
        // ),

        // Text(
        //  vehicle.year ?? '',
        //   overflow: TextOverflow.ellipsis,
        //   style: Theme.of(context).textTheme.titleLarge?.apply(
        //       color: isDark ? FColors.white.withOpacity(.8) : FColors.dark
        //   ),
        // ),
      ],
    );
  }
}
