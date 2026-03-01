import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/models/vehicle.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class InspectionCard extends StatelessWidget {
  const InspectionCard({
    super.key,
    required this.slug,
    this.customerName,
    this.vehicle,
    required this.stage,
    this.rejectedNote,
    required this.onTap,
  });

  final String? slug;
  final String? customerName;
  final Vehicle? vehicle;
  final InspectionStage stage;
  final String? rejectedNote;
  final VoidCallback onTap;

  bool get _isRejected => stage == InspectionStage.rejected;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Card(
          color: isDark ? FColors.black : FColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            side: _isRejected
                ? BorderSide(color: Colors.redAccent.withValues(alpha: 0.4), width: 1)
                : BorderSide.none,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            child: Container(
              decoration: _isRejected
                  ? BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(color: Colors.redAccent, width: 4),
                      ),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(FSizes.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(stage.icon, color: stage.color),
                        const SizedBox(width: FSizes.spaceBtwItems),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                customerName ?? '---',
                                style: Theme.of(context).textTheme.titleMedium?.apply(
                                  color: isDark
                                      ? FColors.white.withValues(alpha: .8)
                                      : FColors.dark,
                                ),
                              ),

                              const SizedBox(height: FSizes.sm),

                              Text(
                                '${vehicle?.make?.label ?? ''} - ${vehicle?.model?.label ?? ''} - ${vehicle?.year ?? ''}',
                                style: Theme.of(context).textTheme.bodyMedium?.apply(
                                  color: isDark
                                      ? FColors.white.withValues(alpha: .8)
                                      : FColors.dark,
                                ),
                              ),

                              const SizedBox(height: FSizes.sm),

                              Row(
                                children: [
                                  vehicle?.make?.avatar != null
                                      ? Image.network(
                                          vehicle!.make!.avatar!,
                                          fit: BoxFit.contain,
                                          width: 30,
                                          height: 30,
                                        )
                                      : SizedBox(),
                                  const SizedBox(width: FSizes.sm),
                                  Text(
                                    vehicle?.plate ?? '',
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
                              '#${slug ?? '---'}',
                              style: Theme.of(context).textTheme.labelMedium?.apply(
                                color: isDark ? FColors.grey : FColors.darkerGrey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: FSizes.spaceBtwItems),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: FSizes.sm),
                              decoration: BoxDecoration(
                                color: stage.color.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(FSizes.sm),
                              ),
                              child: Text(
                                stage.getLabel,
                                style: Theme.of(context).textTheme.bodyLarge?.apply(
                                  color: stage.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Rejection reason banner
                  if (_isRejected && rejectedNote != null && rejectedNote!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.md,
                        vertical: FSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border(
                          top: BorderSide(
                            color: Colors.redAccent.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.warning_2, size: 16, color: Colors.red.shade400),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: Text(
                              rejectedNote!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VehicleRow extends StatelessWidget {
  const VehicleRow({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
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
            color: isDark ? FColors.white.withValues(alpha: .8) : FColors.dark,
          ),
        ),

        // Text(
        //   vehicle.model?.label ?? '',
        //   overflow: TextOverflow.ellipsis,
        //   style: Theme.of(context).textTheme.titleLarge?.apply(
        //       color: isDark ? FColors.white.withValues(alpha: .8) : FColors.dark
        //   ),
        // ),

        // Text(
        //  vehicle.year ?? '',
        //   overflow: TextOverflow.ellipsis,
        //   style: Theme.of(context).textTheme.titleLarge?.apply(
        //       color: isDark ? FColors.white.withValues(alpha: .8) : FColors.dark
        //   ),
        // ),
      ],
    );
  }
}
