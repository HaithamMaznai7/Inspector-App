import 'package:fahis_inspector/features/paint_gauge/components/panel_list.dart';
import 'package:fahis_inspector/features/paint_gauge/controller.dart';
import 'package:fahis_inspector/features/paint_gauge/utils/car_part_label.dart';
import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CurrentReadingPanel extends StatelessWidget {
  final PaintGaugeController controller;

  const CurrentReadingPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaintGaugeController>(
      tag: 'PaintGauge',
      builder: (_) {
        // Device panel takes priority; fall back to selected; default to Hood
        final activePart =
            controller.currentDevicePanel.value ??
            controller.selectedPanel.value ??
            CarPart.frontHatch;

        return _ReadingDisplay(part: activePart, controller: controller);
      },
    );
  }
}

// ── Main reading display ────────────────────────────────────────────────────────

class _ReadingDisplay extends StatelessWidget {
  final CarPart part;
  final PaintGaugeController controller;

  const _ReadingDisplay({required this.part, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Priority: session > cached > backend > empty
    final sessionM = controller.partMeasurements[part];
    final cached = controller.cachedReadingsFor(part);
    final backend = controller.backendPanelFor(part);
    final backendThickness = backend?.thickness;

    // Determine what to display
    late final double? mainValue;
    late final double? avgValue;
    late final String? substrateLabel;
    late final int readingCount;
    late final List<double> slotReadings;
    late final int backendOnlyCount; // >0 means colored slots without values

    if (sessionM != null && sessionM.hasMeasurement) {
      // Active BLE session data
      mainValue = sessionM.latestReading;
      avgValue = sessionM.average;
      substrateLabel = sessionM.substrate?.label;
      readingCount = sessionM.readings.length;
      slotReadings = sessionM.readings;
      backendOnlyCount = 0;
    } else if (cached != null) {
      // User's own cached readings from a previous session
      mainValue = cached.latestReading;
      avgValue = cached.average;
      substrateLabel = cached.substrate;
      readingCount = cached.readings.length;
      slotReadings = cached.readings;
      backendOnlyCount = 0;
    } else if (backend != null && backendThickness != null) {
      // Someone else's data from backend — no individual readings
      mainValue = backendThickness;
      avgValue = backendThickness;
      substrateLabel = backend.substrate;
      readingCount = backend.measurementCount;
      slotReadings = [];
      backendOnlyCount = backend.measurementCount;
    } else {
      // No data at all
      mainValue = null;
      avgValue = null;
      substrateLabel = null;
      readingCount = 0;
      slotReadings = [];
      backendOnlyCount = 0;
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: FSizes.lg,
        vertical: FSizes.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
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
          const SizedBox(height: FSizes.sm),

          // ── Large reading value ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FSizes.lg,
              FSizes.xs,
              FSizes.lg,
              FSizes.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Main value
                Expanded(
                  child: mainValue != null && readingCount > 0
                      ? _LargeValue(
                          value: mainValue,
                          substrateLabel: substrateLabel,
                        )
                      : _NoReadingYet(),
                ),

                // Average + substrate column
                if (mainValue != null && avgValue != null)
                  _StatsColumn(
                    average: avgValue,
                    substrateLabel: substrateLabel,
                    readingCount: readingCount,
                  ),
              ],
            ),
          ),

          // ── 6 reading slots ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FSizes.md,
              FSizes.sm,
              FSizes.md,
              FSizes.md,
            ),
            child: _ReadingSlots(
              readings: slotReadings,
              backendOnlyCount: backendOnlyCount,
            ),
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
      padding: const EdgeInsets.fromLTRB(
        FSizes.lg,
        FSizes.md,
        FSizes.lg,
        FSizes.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NumberBadge(number: part.index + 1),
          const SizedBox(width: FSizes.xs),
          Expanded(
            child: Text(
              part.localizedLabel,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          // Reading count badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.sm + 4,
              vertical: FSizes.xs,
            ),
            decoration: BoxDecoration(
              color: FColors.darkGrey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            child: Text(
              '$readingCount/6',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: readingCount >= 6
                    ? FColors.primaryColor
                    : FColors.darkGrey,
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
                child: Icon(
                  Iconsax.trash,
                  size: FSizes.iconSm,
                  color: FColors.darkGrey.withValues(alpha: 0.6),
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
  final String? substrateLabel;

  const _LargeValue({required this.value, this.substrateLabel});

  String _format(double v) =>
      v.abs() < 99.95 ? v.toStringAsFixed(1) : v.round().toString();

  @override
  Widget build(BuildContext context) {
    final largeFontSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 30.0,
      tablet: 38.0,
    );

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
                fontSize: largeFontSize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.0,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: FSizes.xs),
            Padding(
              padding: const EdgeInsets.only(bottom: FSizes.xs),
              child: Text(
                'μm',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: FColors.darkGrey),
      ),
    );
  }
}

// ── Stats column (right side) ───────────────────────────────────────────────────

class _StatsColumn extends StatelessWidget {
  final double average;
  final String? substrateLabel;
  final int readingCount;

  const _StatsColumn({
    required this.average,
    this.substrateLabel,
    required this.readingCount,
  });

  String _format(double v) =>
      v.abs() < 99.95 ? v.toStringAsFixed(1) : v.round().toString();

  @override
  Widget build(BuildContext context) {
    final isMetalPutty = substrateLabel == 'Metal Putty';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Substrate badge
        if (substrateLabel != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.xs + 2,
            ),
            decoration: BoxDecoration(
              color: isMetalPutty
                  ? FColors.error.withValues(alpha: 0.1)
                  : FColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            child: Text(
              substrateLabel!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isMetalPutty ? FColors.error : FColors.primaryColor,
              ),
            ),
          ),
        const SizedBox(height: FSizes.sm),
        // Average
        if (readingCount > 1) ...[
          Text(
            '${PaintGaugePage.average.tr}: ${_format(average)} μm',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: FColors.darkGrey,
              fontWeight: FontWeight.w700,
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

  /// When >0, show this many colored slots without individual values.
  /// Used for backend-only data where we don't have the individual readings.
  final int backendOnlyCount;

  const _ReadingSlots({required this.readings, this.backendOnlyCount = 0});

  String _format(double v) =>
      v.abs() < 99.95 ? v.toStringAsFixed(1) : v.round().toString();

  @override
  Widget build(BuildContext context) {
    const slotGap = FSizes.xs / 2;

    return Row(
      children: List.generate(6, (i) {
        // Individual reading values available (session or cached)
        if (i < readings.length) {
          final isLatest = i == readings.length - 1;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: i == 0 ? 0 : slotGap,
                right: i == 5 ? 0 : slotGap,
              ),
              padding: const EdgeInsets.symmetric(vertical: FSizes.sm + 2),
              decoration: BoxDecoration(
                color: isLatest
                    ? FColors.primaryColor
                    : FColors.darkGrey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: Text(
                textAlign: TextAlign.center,
                _format(readings[i]),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isLatest
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          );
        }

        // Backend-only colored slots (no individual values)
        if (i < backendOnlyCount) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: i == 0 ? 0 : slotGap,
                right: i == 5 ? 0 : slotGap,
              ),
              padding: const EdgeInsets.symmetric(vertical: FSizes.sm + 2),
              decoration: BoxDecoration(
                color: FColors.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: Text(
                textAlign: TextAlign.center,
                '—',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: FColors.primaryColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        }

        // Empty slot
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: i == 0 ? 0 : slotGap,
              right: i == 5 ? 0 : slotGap,
            ),
            padding: const EdgeInsets.symmetric(vertical: FSizes.sm + 2),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            ),
            child: Text(
              textAlign: TextAlign.center,
              '—',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: FColors.darkGrey.withValues(alpha: 0.3),
              ),
            ),
          ),
        );
      }),
    );
  }
}
