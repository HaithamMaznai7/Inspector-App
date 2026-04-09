import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/features/paint_gauge/utils/car_part_label.dart';
import 'package:fahis_inspector/models/paint_panel.dart';
import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/resources/paint_gauge_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';

class InspectionPaintGaugeReview extends StatelessWidget {
  const InspectionPaintGaugeReview({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionDetailsController>(
      init: InspectionDetailsBinding().instance,
      builder: (c) {
        if (c.isLoading.value || c.inspection.value == null) {
          return const SizedBox.shrink();
        }

        final slug = c.slug;
        if (slug == null) return const SizedBox.shrink();

        // Build map from cached backend panels keyed by id
        final Map<int, PaintPanel> panelMap = {};
        final box = Hive.isBoxOpen(PaintGaugeRepository.boxKey)
            ? Hive.box(PaintGaugeRepository.boxKey)
            : null;

        if (box != null) {
          final raw = box.get('panels_$slug');
          if (raw != null) {
            try {
              for (final e in raw as List) {
                final panel = PaintPanel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                );
                panelMap[panel.id] = panel;
              }
            } catch (_) {}
          }
        }

        // Filter to CarParts that have saved thickness
        final measuredParts = CarPart.values
            .where((part) => panelMap[part.backendId]?.thickness != null)
            .toList();

        return InfoCard(
          title: Text(PaintGaugePage.reviewTitle.tr),
          tilePadding: FSizes.md,
          icon: Iconsax.brush_1,
          iconColor: FColors.primaryColor,
          children: [
            if (measuredParts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(FSizes.md),
                child: Text(
                  PaintGaugePage.reviewNoData.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: FColors.darkGrey,
                      ),
                ),
              )
            else
              _PaintGaugeSummary(
                measuredParts: measuredParts,
                panelMap: panelMap,
                totalPanels: CarPart.values.length,
              ),
          ],
        );
      },
    );
  }
}

class _PaintGaugeSummary extends StatelessWidget {
  final List<CarPart> measuredParts;
  final Map<int, PaintPanel> panelMap;
  final int totalPanels;

  const _PaintGaugeSummary({
    required this.measuredParts,
    required this.panelMap,
    required this.totalPanels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary header
        Padding(
          padding: const EdgeInsets.fromLTRB(
              FSizes.md, 0, FSizes.md, FSizes.sm),
          child: _StatChip(
            label: PaintGaugePage.reviewPanelsMeasured.tr,
            value: '${measuredParts.length}/$totalPanels',
            color: measuredParts.length >= totalPanels
                ? FColors.success
                : FColors.primaryColor,
          ),
        ),

        const Divider(height: 1),

        // Per-panel rows
        ...measuredParts.map((part) => _PanelRow(
              part: part,
              panel: panelMap[part.backendId]!,
            )),
        const SizedBox(height: FSizes.sm),
      ],
    );
  }
}

class _PanelRow extends StatelessWidget {
  final CarPart part;
  final PaintPanel panel;

  const _PanelRow({required this.part, required this.panel});

  @override
  Widget build(BuildContext context) {
    final avg = panel.thickness;
    final substrate = panel.substrate ?? '';
    final count = panel.measurementCount;
    final isComplete = count >= 6;

    Color substrateColor = FColors.darkGrey;
    if (substrate == 'Metal Putty') substrateColor = FColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md, vertical: FSizes.xs),
      child: Row(
        children: [
          Container(
            width: FSizes.xs,
            height: FSizes.xl,
            decoration: BoxDecoration(
              color: isComplete ? FColors.primaryColor : FColors.darkGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Text(
              part.localizedLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            '$count/6',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: FColors.darkGrey,
                ),
          ),
          const SizedBox(width: FSizes.sm),
          if (avg != null)
            Text(
              '${avg.toStringAsFixed(avg.abs() < 99.95 ? 1 : 0)} μm',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          const SizedBox(width: FSizes.xs),
          if (substrate.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.xs, vertical: 2),
              decoration: BoxDecoration(
                color: substrateColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: Text(
                substrate,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: substrateColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.labelSmall,
          children: [
            TextSpan(
                text: '$label: ', style: TextStyle(color: FColors.darkGrey)),
            TextSpan(
                text: value,
                style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
