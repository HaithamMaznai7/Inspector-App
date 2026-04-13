import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/features/inspection_points/components/note_dialog.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/point.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PointCard extends StatefulWidget {
  const PointCard({super.key, required this.point, required this.onChange});
  final Point point;
  final Future<void> Function(Point point, PointStatus status) onChange;

  @override
  State<PointCard> createState() => _PointCardState();
}

class _PointCardState extends State<PointCard> {
  late Point _point;

  @override
  void initState() {
    super.initState();
    _point = widget.point;
  }

  @override
  void didUpdateWidget(covariant PointCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.point != widget.point ||
        oldWidget.onChange != widget.onChange) {
      setState(() => _point = widget.point);
    }
  }

  Future<void> _setStatus(PointStatus status) async {
    Point newPoint = _point;
    try {
      if (status == PointStatus.note) {
        final result = await Get.dialog<Point>(
          InspectionNotesDialog(_point),
          barrierDismissible: false,
        );
        if (result == null) return;
        newPoint = result;
      }
      newPoint.setStatus = status;
      setState(() => _point = newPoint);
      await widget.onChange(newPoint, status);
      if (status == PointStatus.note) {
        FLoader.successSnackBar(message: InspectionPage.noteSavedSuccessMsg.tr);
      }
    } catch (e) {
      dd(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    final chipHeight = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 32,
      tablet: 36,
      desktop: 40,
    );
    final chipFontSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 11,
      tablet: 12,
      desktop: 13,
    );
    final chipIconSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 13,
      tablet: 14,
      desktop: 15,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FSizes.md,
          FSizes.md,
          FSizes.md,
          FSizes.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Point title ────────────────────────────────────────────────
            Text(
              _point.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: FSizes.sm),

            // ── Radio-style selector row ───────────────────────────────────
            // Active chip: light colored tint + colored border + colored text.
            // Feels like "I selected this" (a radio option), NOT a CTA button.
            // Inactive chip: neutral ghost + muted text — "available, not chosen".
            Row(
              children: [
                _RadioChip(
                  status: PointStatus.good,
                  current: _point.status,
                  height: chipHeight,
                  fontSize: chipFontSize,
                  iconSize: chipIconSize,
                  isDark: isDark,
                  onTap: () => _setStatus(PointStatus.good),
                ),
                const SizedBox(width: FSizes.xs),
                _RadioChip(
                  status: PointStatus.note,
                  current: _point.status,
                  height: chipHeight,
                  fontSize: chipFontSize,
                  iconSize: chipIconSize,
                  isDark: isDark,
                  onTap: () => _setStatus(PointStatus.note),
                ),
                const SizedBox(width: FSizes.xs),
                _RadioChip(
                  status: PointStatus.none,
                  current: _point.status,
                  height: chipHeight,
                  fontSize: chipFontSize,
                  iconSize: chipIconSize,
                  isDark: isDark,
                  onTap: () => _setStatus(PointStatus.none),
                ),
              ],
            ),

            // ── Note preview ───────────────────────────────────────────────
            if (_point.status == PointStatus.note) ...[
              const SizedBox(height: FSizes.xs),
              GestureDetector(
                onTap: () => _setStatus(PointStatus.note),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: FSizes.iconXs,
                      color: FColors.warning.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: FSizes.xs),
                    Expanded(
                      child: Text(
                        _point.note?.isNotEmpty == true ? _point.note! : '...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FColors.warning,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: FSizes.xs),
          ],
        ),
      ),
    );
  }
}

// ── Radio-style chip ──────────────────────────────────────────────────────────
//
// Selected state: light tinted background + colored border + bold colored text.
// This reads as "I chose this" rather than "tap me to do something".
// Unselected state: near-invisible ghost — available but not chosen.

class _RadioChip extends StatelessWidget {
  final PointStatus status;
  final PointStatus current;
  final double height;
  final double fontSize;
  final double iconSize;
  final bool isDark;
  final VoidCallback onTap;

  const _RadioChip({
    required this.status,
    required this.current,
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.isDark,
    required this.onTap,
  });

  bool get _isActive => status == current;
  Color get _statusColor => status.color();

  // N/A is the backend default — keep it more visible when inactive so
  // inspectors can clearly read the option label on every unanswered card.
  bool get _isNa => status == PointStatus.none;

  @override
  Widget build(BuildContext context) {
    final bg = _isActive
        ? _statusColor.withValues(alpha: (_isActive && _isNa) ? 0.40 : 0.10)
        : (isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04));

    final borderColor = _isActive
        ? _statusColor.withValues(alpha: (_isActive && _isNa) ? 0.90 : 0.65)
        : (isDark
              ? Colors.white.withValues(alpha: _isNa ? 0.20 : 0.10)
              : Colors.black.withValues(alpha: _isNa ? 0.18 : 0.08));

    final contentColor = _isActive
        ? _statusColor
        : (isDark
              ? Colors.white.withValues(alpha: _isNa ? 0.50 : 0.30)
              : Colors.black.withValues(alpha: _isNa ? 0.45 : 0.28));

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            border: Border.all(
              color: borderColor,
              width: _isActive ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(status.icon(), size: iconSize, color: contentColor),
              const SizedBox(width: FSizes.xxs),
              Text(
                status.toString(),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: _isActive ? FontWeight.w700 : FontWeight.w400,
                  color: contentColor,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
