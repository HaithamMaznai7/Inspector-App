import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/paint_gauge_result.dart';
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

        // Load cached paint gauge result from Hive
        final box = Hive.isBoxOpen(PaintGaugeRepository.boxKey)
            ? Hive.box(PaintGaugeRepository.boxKey)
            : null;

        PaintGaugeResult? result;
        if (box != null) {
          final raw = box.get(slug);
          if (raw != null) {
            try {
              result = PaintGaugeResult.fromJson(
                  Map<String, dynamic>.from(raw as Map));
            } catch (_) {}
          }
        }

        return InfoCard(
          title: Text(PaintGaugePage.reviewTitle.tr),
          tilePadding: FSizes.md,
          icon: Iconsax.brush_1,
          iconColor: FColors.primaryColor,
          children: [
            if (result == null || result.totalPanelsMeasured == 0)
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
              _PaintGaugeSummary(result: result),
          ],
        );
      },
    );
  }
}

class _PaintGaugeSummary extends StatelessWidget {
  final PaintGaugeResult result;
  const _PaintGaugeSummary({required this.result});

  @override
  Widget build(BuildContext context) {
    final measuredPanels = result.panels.values
        .where((r) => r.measurementCount > 0)
        .toList()
      ..sort((a, b) => a.panelName.compareTo(b.panelName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary header
        Padding(
          padding: const EdgeInsets.fromLTRB(
              FSizes.md, 0, FSizes.md, FSizes.sm),
          child: Row(
            children: [
              _StatChip(
                label: PaintGaugePage.reviewPanelsMeasured.tr,
                value: '${result.totalPanelsMeasured}/19',
                color: result.totalPanelsMeasured >= 19
                    ? FColors.success
                    : FColors.primaryColor,
              ),
              const SizedBox(width: FSizes.sm),
              if (result.deviceName != null)
                _StatChip(
                  label: 'Device',
                  value: result.deviceName!,
                  color: FColors.darkGrey,
                ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Per-panel rows
        ...measuredPanels.map((reading) => _PanelRow(reading: reading)),
        const SizedBox(height: FSizes.sm),
      ],
    );
  }
}

class _PanelRow extends StatelessWidget {
  final dynamic reading; // PaintGaugeReading
  const _PanelRow({required this.reading});

  @override
  Widget build(BuildContext context) {
    final isComplete = reading.isComplete as bool;
    final avg = reading.averageThickness as double?;
    final substrate = reading.substrate as String;
    final count = reading.measurementCount as int;

    Color substrateColor = FColors.darkGrey;
    if (substrate == 'Metal Putty') substrateColor = FColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md, vertical: FSizes.xs),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: isComplete ? FColors.primaryColor : FColors.darkGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Text(
              reading.panelName as String,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            '$count/6',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: FColors.darkGrey,
                  fontSize: 11,
                ),
          ),
          const SizedBox(width: FSizes.sm),
          if (avg != null)
            Text(
              '${avg.toStringAsFixed(avg.abs() < 99.95 ? 1 : 0)} μm',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          const SizedBox(width: FSizes.xs),
          if (substrate.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.xs, vertical: 2),
              decoration: BoxDecoration(
                color: substrateColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                substrate,
                style: TextStyle(
                  fontSize: 10,
                  color: substrateColor,
                  fontWeight: FontWeight.w600,
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
          style: const TextStyle(fontSize: 11),
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
