import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/models/vehicle.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
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
    this.inspectionTypeTitle,
    required this.onTap,
  });

  final String? slug;
  final String? customerName;
  final Vehicle? vehicle;
  final InspectionStage stage;
  final String? rejectedNote;
  final String? inspectionTypeTitle;
  final VoidCallback onTap;

  bool get _isRejected => stage == InspectionStage.rejected;

  String _vehicleLabel() {
    final parts = [
      vehicle?.make?.label,
      vehicle?.model?.label,
      vehicle?.year,
    ].where((e) => e != null && e.isNotEmpty).map((e) => e!).toList();
    return parts.isEmpty ? '---' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    final cardBg = isDark ? FColors.black : Colors.white;
    final borderColor = isDark
        ? FColors.grey.withValues(alpha: 0.1)
        : FColors.grey.withValues(alpha: 0.25);

    final pad = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: FSizes.md,
      tablet: FSizes.lg,
    );
    final logoSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: FSizes.iconInlineSm,
      tablet: FSizes.iconInlineMd,
    );
    final labelSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 11,
      tablet: 13,
    );
    final detailSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 12,
      tablet: 14,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Stage accent bar ───────────────────────────────
                  Container(width: 4, color: stage.color),

                  // ── Card body ──────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            pad,
                            pad,
                            pad,
                            FSizes.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1: customer name + type badge + slug badge
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      customerName ?? '---',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? FColors.light
                                                : FColors.dark,
                                          ),
                                    ),
                                  ),
                                  if (inspectionTypeTitle != null &&
                                      inspectionTypeTitle!.isNotEmpty) ...[
                                    const SizedBox(width: FSizes.sm),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: FSizes.sm,
                                        vertical: FSizes.xs - 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: FColors.info.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          FSizes.borderRadiusSm,
                                        ),
                                        border: Border.all(
                                          color: FColors.info.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        inspectionTypeTitle!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: labelSize,
                                          fontWeight: FontWeight.w700,
                                          color: FColors.info,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: FSizes.sm),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: FSizes.sm,
                                      vertical: FSizes.xs - 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? FColors.grey.withValues(alpha: 0.08)
                                          : FColors.grey.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(
                                        FSizes.borderRadiusSm,
                                      ),
                                    ),
                                    child: Text(
                                      '#${slug ?? '---'}',
                                      style: TextStyle(
                                        fontSize: labelSize,
                                        fontWeight: FontWeight.w600,
                                        color: FColors.darkGrey,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: FSizes.xs + 1),

                              // Row 2: Make · Model · Year
                              Text(
                                _vehicleLabel(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? FColors.grey
                                          : FColors.darkGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),

                              const SizedBox(height: FSizes.sm),

                              Divider(
                                height: 1,
                                color: isDark
                                    ? FColors.grey.withValues(alpha: 0.08)
                                    : FColors.grey.withValues(alpha: 0.35),
                              ),

                              const SizedBox(height: FSizes.sm),

                              // Row 3: plate • stage pill
                              Row(
                                children: [
                                  // Brand logo + plate — Flexible so it yields
                                  // space to the stage pill on narrow screens
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (vehicle?.make?.avatar != null) ...[
                                          CachedNetworkImage(
                                            imageUrl: vehicle!.make!.avatar!,
                                            width: logoSize,
                                            height: logoSize,
                                            fit: BoxFit.contain,
                                            placeholder: (_, _) => SizedBox(
                                              width: logoSize,
                                              height: logoSize,
                                            ),
                                            errorWidget: (_, _, _) => Icon(
                                              Iconsax.car,
                                              size: FSizes.iconSm,
                                              color: FColors.darkGrey,
                                            ),
                                          ),
                                          const SizedBox(width: FSizes.xs + 2),
                                        ],
                                        if (vehicle?.plate != null &&
                                            vehicle!.plate!.isNotEmpty)
                                          Flexible(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: FSizes.sm,
                                                vertical: FSizes.xs,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: isDark
                                                      ? FColors.grey.withValues(
                                                          alpha: 0.2,
                                                        )
                                                      : FColors.darkGrey
                                                            .withValues(
                                                              alpha: 0.45,
                                                            ),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      FSizes.borderRadiusMd,
                                                    ),
                                              ),
                                              child: Text(
                                                vehicle!.plate!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: detailSize,
                                                  fontWeight: FontWeight.w700,
                                                  color: FColors.primaryColor,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          Icon(
                                            Iconsax.car,
                                            size: FSizes.iconSm,
                                            color: FColors.grey,
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: FSizes.sm),

                                  // Stage pill — shrinks label if needed
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: FSizes.sm + 2,
                                      vertical: FSizes.xs + 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: stage.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        FSizes.borderRadiusLg,
                                      ),
                                      border: Border.all(
                                        color: stage.color.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          stage.icon,
                                          size: FSizes.iconXs,
                                          color: stage.color,
                                        ),
                                        const SizedBox(width: FSizes.xs + 1),
                                        Text(
                                          stage.getLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: detailSize,
                                            fontWeight: FontWeight.w600,
                                            color: stage.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── Rejection banner ──────────────────────────
                        if (_isRejected &&
                            rejectedNote != null &&
                            rejectedNote!.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: pad,
                              vertical: FSizes.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.red.withValues(alpha: 0.08)
                                  : Colors.red.shade50,
                              border: Border(
                                top: BorderSide(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Iconsax.warning_2,
                                  size: FSizes.iconXs + 2,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: FSizes.xs),
                                Expanded(
                                  child: Text(
                                    rejectedNote!,
                                    style: TextStyle(
                                      fontSize: detailSize,
                                      color: isDark
                                          ? Colors.red.shade300
                                          : Colors.red.shade700,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
