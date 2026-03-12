import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/features/inspection_points/components/note_dialog.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/point.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
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
        // Always open the note dialog for note status, even if already set,
        // so the inspector can review / update the note text and photo.
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
    } catch (e) {
      dd(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    final chipHeight = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 38,
      tablet: 42,
      desktop: 46,
    );
    final chipFontSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 12,
      tablet: 13,
      desktop: 14,
    );
    final chipIconSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 14,
      tablet: 15,
      desktop: 16,
    );

    return Card(
      elevation: 1,
      shadowColor: FColors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
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
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: FSizes.sm),

            // ── Labeled segmented chips ────────────────────────────────────
            // Three equal-width chips spanning the full card width.
            // Text + icon on each chip makes the choice self-describing for
            // first-time users — no need to guess icon meanings.
            Row(
              children: [
                _StatusChip(
                  status: PointStatus.good,
                  current: _point.status,
                  height: chipHeight,
                  fontSize: chipFontSize,
                  iconSize: chipIconSize,
                  isDark: isDark,
                  onTap: () => _setStatus(PointStatus.good),
                ),
                const SizedBox(width: FSizes.xs),
                _StatusChip(
                  status: PointStatus.note,
                  current: _point.status,
                  height: chipHeight,
                  fontSize: chipFontSize,
                  iconSize: chipIconSize,
                  isDark: isDark,
                  onTap: () => _setStatus(PointStatus.note),
                ),
                const SizedBox(width: FSizes.xs),
                _StatusChip(
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
            // Shown as a compact tappable row below the chips so it doesn't
            // disrupt the visual rhythm of the list. Tapping it re-opens the
            // note dialog for editing.
            if (_point.status == PointStatus.note) ...[
              const SizedBox(height: FSizes.xs),
              GestureDetector(
                onTap: () => _setStatus(PointStatus.note),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: FColors.warning.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    border: Border.all(
                      color: FColors.warning.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PointStatus.note.icon(),
                        color: FColors.warning,
                        size: 14,
                      ),
                      const SizedBox(width: FSizes.xs),
                      Expanded(
                        child: Text(
                          _point.note?.isNotEmpty == true
                              ? _point.note!
                              : '...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? FColors.grey
                                    : FColors.darkerGrey,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: FSizes.xs),
                      Icon(
                        Icons.edit_outlined,
                        size: 13,
                        color: FColors.warning.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
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

// ── Labeled status chip ───────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final PointStatus status;
  final PointStatus current;
  final double height;
  final double fontSize;
  final double iconSize;
  final bool isDark;
  final VoidCallback onTap;

  const _StatusChip({
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

  @override
  Widget build(BuildContext context) {
    final bg = _isActive
        ? _statusColor
        : (isDark
            ? _statusColor.withValues(alpha: 0.12)
            : _statusColor.withValues(alpha: 0.08));

    final contentColor = _isActive
        ? Colors.white
        : _statusColor.withValues(alpha: isDark ? 0.75 : 0.65);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          height: height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            border: _isActive
                ? null
                : Border.all(
                    color: _statusColor.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(status.icon(), size: iconSize, color: contentColor),
              const SizedBox(width: 4),
              Text(
                status.toString(),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight:
                      _isActive ? FontWeight.w700 : FontWeight.w500,
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
