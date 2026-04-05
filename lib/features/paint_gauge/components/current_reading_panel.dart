import 'package:fahis_inspector/features/paint_gauge/controller.dart';
import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CurrentReadingPanel extends StatelessWidget {
  final PaintGaugeController controller;

  const CurrentReadingPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaintGaugeController>(
      tag: 'PaintGauge',
      builder: (_) {
        // Device panel takes priority; fall back to selected; default to Hood
        final activePart = controller.currentDevicePanel.value ??
            controller.selectedPanel.value ??
            CarPart.frontHatch;

        final measurement = controller.partMeasurements[activePart];
        return _ReadingDisplay(
          part: activePart,
          measurement: measurement,
          controller: controller,
        );
      },
    );
  }
}

// ── Main reading display ────────────────────────────────────────────────────────

class _ReadingDisplay extends StatelessWidget {
  final CarPart part;
  final PartMeasurement? measurement;
  final PaintGaugeController controller;

  const _ReadingDisplay({
    required this.part,
    required this.measurement,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final m = measurement;
    final hasReadings = m != null && m.hasMeasurement;
    final latest = m?.latestReading;
    final avg = m?.average;
    final substrate = m?.substrate;
    final readingCount = m?.readings.length ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: FSizes.md, vertical: FSizes.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: FColors.darkGrey.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Panel name header ──
          _PanelHeader(
            part: part,
            readingCount: readingCount,
            controller: controller,
          ),

          const Divider(height: 1),

          // ── Large reading value ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                FSizes.lg, FSizes.md, FSizes.lg, FSizes.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Main value
                Expanded(
                  child: hasReadings && latest != null
                      ? _LargeValue(
                          value: latest,
                          substrate: substrate,
                        )
                      : _NoReadingYet(),
                ),

                // Average + substrate column
                if (hasReadings && avg != null)
                  _StatsColumn(
                    average: avg,
                    substrate: substrate,
                    readingCount: readingCount,
                  ),
              ],
            ),
          ),

          // ── 6 reading slots ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                FSizes.md, FSizes.sm, FSizes.md, FSizes.md),
            child: _ReadingSlots(readings: m?.readings ?? []),
          ),
        ],
      ),
    );
  }
}

// ── Panel header ────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final CarPart part;
  final int readingCount;
  final PaintGaugeController controller;

  const _PanelHeader({
    required this.part,
    required this.readingCount,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md, vertical: FSizes.sm),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: readingCount >= 6
                  ? FColors.primaryColor
                  : readingCount > 0
                      ? FColors.darkGrey
                      : Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Text(
              '${CarPart.values.indexOf(part) + 1}) ${part.label}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          // Reading count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: readingCount >= 6
                  ? FColors.primaryColor.withValues(alpha: 0.12)
                  : FColors.darkGrey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$readingCount/6',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color:
                    readingCount >= 6 ? FColors.primaryColor : FColors.darkGrey,
              ),
            ),
          ),
          const SizedBox(width: FSizes.xs),
          // Clear button
          if (readingCount > 0)
            GestureDetector(
              onTap: () => _confirmClear(context),
              child: Padding(
                padding: const EdgeInsets.all(FSizes.xs),
                child: Text(
                  PaintGaugePage.clearPanel.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: FColors.darkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(PaintGaugePage.clearPanel.tr),
        content: Text(PaintGaugePage.clearPanelConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(FTexts.cancelBtn.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              FTexts.deleteBtn.tr,
              style: const TextStyle(color: FColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.clearPanel(part);
    }
  }
}

// ── Large value display ─────────────────────────────────────────────────────────

class _LargeValue extends StatelessWidget {
  final double value;
  final SubstrateType? substrate;

  const _LargeValue({required this.value, this.substrate});

  String _format(double v) =>
      v.abs() < 99.95 ? v.toStringAsFixed(1) : v.round().toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _format(value),
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.0,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'μm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: FColors.darkGrey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NoReadingYet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
      child: Text(
        PaintGaugePage.noMeasurementYet.tr,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FColors.darkGrey,
            ),
      ),
    );
  }
}

// ── Stats column (right side) ───────────────────────────────────────────────────

class _StatsColumn extends StatelessWidget {
  final double average;
  final SubstrateType? substrate;
  final int readingCount;

  const _StatsColumn({
    required this.average,
    this.substrate,
    required this.readingCount,
  });

  String _format(double v) =>
      v.abs() < 99.95 ? v.toStringAsFixed(1) : v.round().toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Substrate badge
        if (substrate != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: substrate == SubstrateType.metalPutty
                  ? FColors.error.withValues(alpha: 0.12)
                  : FColors.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              substrate!.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: substrate == SubstrateType.metalPutty
                    ? FColors.error
                    : FColors.primaryColor,
              ),
            ),
          ),
        const SizedBox(height: FSizes.sm),
        // Average
        if (readingCount > 1) ...[
          Text(
            '${PaintGaugePage.average.tr}:',
            style: TextStyle(
              fontSize: 11,
              color: FColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${_format(average)} μm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ],
    );
  }
}

// ── 6 reading slots ─────────────────────────────────────────────────────────────

class _ReadingSlots extends StatelessWidget {
  final List<double> readings;

  const _ReadingSlots({required this.readings});

  String _format(double v) =>
      v.abs() < 99.95 ? v.toStringAsFixed(1) : v.round().toString();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(6, (i) {
        final hasValue = i < readings.length;
        final isLatest = hasValue && i == readings.length - 1;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: i == 0 ? 0 : 3,
              right: i == 5 ? 0 : 3,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: hasValue
                  ? isLatest
                      ? FColors.primaryColor.withValues(alpha: 0.15)
                      : FColors.darkGrey.withValues(alpha: 0.08)
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              border: Border.all(
                color: isLatest
                    ? FColors.primaryColor.withValues(alpha: 0.4)
                    : Theme.of(context).dividerColor,
                width: isLatest ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasValue ? _format(readings[i]) : '—',
                  style: TextStyle(
                    fontSize: hasValue ? 14 : 16,
                    fontWeight: hasValue ? FontWeight.w700 : FontWeight.w300,
                    color: hasValue
                        ? isLatest
                            ? FColors.primaryColor
                            : Theme.of(context).textTheme.bodyLarge?.color
                        : FColors.darkGrey.withValues(alpha: 0.4),
                  ),
                ),
                if (hasValue)
                  Text(
                    'μm',
                    style: TextStyle(
                      fontSize: 9,
                      color: FColors.darkGrey,
                    ),
                  )
                else
                  const SizedBox(height: 11),
              ],
            ),
          ),
        );
      }),
    );
  }
}
