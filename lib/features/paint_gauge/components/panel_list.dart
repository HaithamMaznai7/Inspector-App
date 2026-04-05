import 'package:fahis_inspector/features/paint_gauge/controller.dart';
import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PanelListWidget extends StatelessWidget {
  final PaintGaugeController controller;

  const PanelListWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaintGaugeController>(
      tag: 'PaintGauge',
      builder: (_) => Column(
        children: CarPart.values
            .map((part) => _PanelTile(controller: controller, part: part))
            .toList(),
      ),
    );
  }
}

class _PanelTile extends StatefulWidget {
  final PaintGaugeController controller;
  final CarPart part;

  const _PanelTile({required this.controller, required this.part});

  @override
  State<_PanelTile> createState() => _PanelTileState();
}

class _PanelTileState extends State<_PanelTile> {
  bool _expanded = false;

  PaintGaugeController get _c => widget.controller;
  CarPart get _part => widget.part;

  PartMeasurement? get _measurement => _c.partMeasurements[_part];

  Color _indicatorColor(BuildContext context) {
    if (_c.panelIsComplete(_part)) return FColors.primaryColor;
    if (_c.panelIsPartial(_part)) return FColors.darkGrey;
    return Theme.of(context).dividerColor;
  }

  Color _tileBackgroundColor(BuildContext context) {
    if (_c.panelIsSelected(_part)) {
      return FColors.primaryColor.withValues(alpha: 0.06);
    }
    return Theme.of(context).cardColor;
  }

  void _onTap() {
    _c.selectPanel(_part);
    setState(() => _expanded = !_expanded);
  }

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
      await _c.clearPanel(_part);
    }
  }

  String _panelLabel() {
    // Map CarPart to localization key
    switch (_part) {
      case CarPart.frontHatch:
        return PaintGaugePage.panelHood.tr;
      case CarPart.roof:
        return PaintGaugePage.panelRoof.tr;
      case CarPart.trunkCover:
        return PaintGaugePage.panelTrunk.tr;
      case CarPart.flWing:
        return PaintGaugePage.panelLeftFrontFender.tr;
      case CarPart.lAColumn:
        return PaintGaugePage.panelLeftAPillar.tr;
      case CarPart.flDoor:
        return PaintGaugePage.panelLeftFrontDoor.tr;
      case CarPart.lBColumn:
        return PaintGaugePage.panelLeftBPillar.tr;
      case CarPart.blDoor:
        return PaintGaugePage.panelLeftRearDoor.tr;
      case CarPart.lCColumn:
        return PaintGaugePage.panelLeftCPillar.tr;
      case CarPart.blWing:
        return PaintGaugePage.panelLeftRearFender.tr;
      case CarPart.lDColumn:
        return PaintGaugePage.panelLeftDPillar.tr;
      case CarPart.rDColumn:
        return PaintGaugePage.panelRightDPillar.tr;
      case CarPart.brWing:
        return PaintGaugePage.panelRightRearFender.tr;
      case CarPart.rCColumn:
        return PaintGaugePage.panelRightCPillar.tr;
      case CarPart.brDoor:
        return PaintGaugePage.panelRightRearDoor.tr;
      case CarPart.rBColumn:
        return PaintGaugePage.panelRightBPillar.tr;
      case CarPart.frDoor:
        return PaintGaugePage.panelRightFrontDoor.tr;
      case CarPart.rAColumn:
        return PaintGaugePage.panelRightAPillar.tr;
      case CarPart.frWing:
        return PaintGaugePage.panelRightFrontFender.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = _measurement;
    final hasData = m?.hasMeasurement ?? false;
    final indicatorColor = _indicatorColor(context);
    final bgColor = _tileBackgroundColor(context);
    final isSelected = _c.panelIsSelected(_part);
    final isDeviceActive = _c.panelIsActiveOnDevice(_part);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.xs / 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        border: Border.all(
          color: isSelected
              ? FColors.primaryColor.withValues(alpha: 0.5)
              : Theme.of(context).dividerColor,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: FColors.primaryColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _onTap,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.sm,
              ),
              child: Row(
                children: [
                  // Color indicator
                  Container(
                    width: 4,
                    height: 36,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.circular(
                        FSizes.borderRadiusSm,
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.sm),

                  // Panel name + device indicator
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _panelLabel(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                            ),
                            if (isDeviceActive) ...[
                              const SizedBox(width: FSizes.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: FColors.primaryColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  PaintGaugePage.here.tr,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: FColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (hasData) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${m!.readings.length}/6 ${PaintGaugePage.readings.tr}  •  ${PaintGaugePage.average.tr}: ${m.average?.toStringAsFixed(1) ?? '--'} μm',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: FColors.darkGrey,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Reading count badge
                  if (hasData) ...[
                    _ReadingBadge(count: m!.readings.length),
                    const SizedBox(width: FSizes.xs),
                  ],

                  Icon(
                    _expanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                    size: FSizes.iconSm,
                    color: FColors.darkGrey,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_expanded && hasData) _buildDetails(context, m!),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context, PartMeasurement m) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        FSizes.md + 4,
        0,
        FSizes.md,
        FSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: FSizes.sm),

          // Individual readings row
          Wrap(
            spacing: FSizes.xs,
            runSpacing: FSizes.xs,
            children: m.readings.asMap().entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.sm,
                  vertical: FSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  '${e.value.toStringAsFixed(e.value.abs() < 99.95 ? 1 : 0)} μm',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: FSizes.sm),

          // Average + substrate
          Row(
            children: [
              if (m.average != null) ...[
                _InfoChip(
                  label: PaintGaugePage.average.tr,
                  value:
                      '${m.average!.toStringAsFixed(m.average!.abs() < 99.95 ? 1 : 0)} μm',
                  color: _c.panelIsComplete(_part)
                      ? FColors.primaryColor
                      : FColors.darkGrey,
                ),
                const SizedBox(width: FSizes.xs),
              ],
              if (m.substrate != null)
                _InfoChip(
                  label: PaintGaugePage.substrate.tr,
                  value: m.substrate!.label,
                  color: m.substrate == SubstrateType.metalPutty
                      ? FColors.error
                      : FColors.darkGrey,
                ),
              const Spacer(),
              // Clear button
              TextButton.icon(
                onPressed: () => _onClear(context),
                icon: const Icon(Iconsax.trash, size: FSizes.iconSm),
                label: Text(PaintGaugePage.clearPanel.tr),
                style: TextButton.styleFrom(
                  foregroundColor: FColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.sm,
                    vertical: FSizes.xs,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadingBadge extends StatelessWidget {
  final int count;
  const _ReadingBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final isComplete = count >= 6;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isComplete ? FColors.primaryColor : FColors.darkGrey)
            .withValues(alpha: 0.12),
      ),
      child: Center(
        child: Text(
          '$count',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isComplete ? FColors.primaryColor : FColors.darkGrey,
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: FColors.darkGrey),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
