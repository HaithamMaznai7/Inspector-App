import 'package:fahis_inspector/features/paint_gauge/controller.dart';
import 'package:fahis_inspector/features/paint_gauge/utils/car_part_label.dart';
import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PanelListWidget extends StatelessWidget {
  final PaintGaugeController controller;
  final Map<CarPart, GlobalKey>? panelKeys;

  const PanelListWidget({super.key, required this.controller, this.panelKeys});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaintGaugeController>(
      tag: 'PaintGauge',
      builder: (_) {
        return Column(
          children: CarPart.values
              .asMap()
              .entries
              .map(
                (e) => _PanelTile(
                  key: panelKeys?[e.value],
                  controller: controller,
                  part: e.value,
                  number: e.key + 1,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PanelTile extends StatelessWidget {
  final PaintGaugeController controller;
  final CarPart part;
  final int number;

  const _PanelTile({
    super.key,
    required this.controller,
    required this.part,
    required this.number,
  });

  Future<void> _onClear(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    // Use merged display helpers
    final readingCount = controller.displayMeasurementCount(part);
    final hasData = readingCount > 0;
    final isDeviceActive = controller.panelIsActiveOnDevice(part);
    final hasSessionData = controller.partMeasurements[part]?.hasMeasurement ?? false;

    return GestureDetector(
      onTap: () => controller.selectPanel(part),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(
          horizontal: FSizes.lg,
          vertical: FSizes.xs / 2,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm + 4,
        ),
        decoration: BoxDecoration(
          color: isDeviceActive
              ? FColors.primaryColor.withValues(alpha: 0.05)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: isDeviceActive
                ? FColors.primaryColor.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            NumberBadge(number: number),
            const SizedBox(width: FSizes.sm),

            // Panel name
            Expanded(
              child: Text(
                part.localizedLabel,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: FSizes.xs),

            // 6 mini column indicators
            // Session data = full opacity orange; backend-only = dimmer
            _MiniReadingIndicators(
              readingCount: readingCount,
              isSessionData: hasSessionData,
            ),

            // Trash icon — only when panel has data
            if (hasData) ...[
              const SizedBox(width: FSizes.xs),
              GestureDetector(
                onTap: () => _onClear(context),
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
          ],
        ),
      ),
    );
  }
}

// ── Number badge ────────────────────────────────────────────────────────────────

class NumberBadge extends StatelessWidget {
  final int number;

  const NumberBadge({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: FSizes.iconMd,
      height: FSizes.iconMd,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: FColors.darkGrey.withValues(alpha: 0.10),
      ),
      child: Center(
        child: Text(
          '$number',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: FColors.darkGrey,
          ),
        ),
      ),
    );
  }
}

// ── 6 mini column indicators ────────────────────────────────────────────────────

class _MiniReadingIndicators extends StatelessWidget {
  final int readingCount;
  final bool isSessionData;

  const _MiniReadingIndicators({
    required this.readingCount,
    this.isSessionData = true,
  });

  @override
  Widget build(BuildContext context) {
    // Session data uses full-opacity orange; backend-only uses dimmer shade
    final filledAlpha = isSessionData ? 0.75 : 0.4;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (i) {
        final filled = i < readingCount;
        return Container(
          width: FSizes.sm,
          height: FSizes.sm,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: filled
                ? FColors.primaryColor.withValues(alpha: filledAlpha)
                : Theme.of(context).dividerColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
