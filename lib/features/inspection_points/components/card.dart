import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/features/inspection_points/components/note_dialog.dart';
import 'package:fahis_inspector/features/inspection_points/components/status_bottom_sheet.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/point.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return Slidable(
      closeOnScroll: true,
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: .7,
        children: [
          SlidableAction(
            autoClose: true,
            borderRadius: BorderRadius.circular(15),
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: FColors.success,
            icon: Icons.gpp_good,
            onPressed: (context) => _setStatus(PointStatus.good),
          ),
          SlidableAction(
            autoClose: true,
            borderRadius: BorderRadius.circular(15),
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: FColors.warning,
            icon: Icons.edit,
            onPressed: (context) => _setStatus(PointStatus.note),
          ),
          SlidableAction(
            autoClose: true,
            borderRadius: BorderRadius.circular(15),
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: isDark ? FColors.darkGrey : FColors.darkGrey,
            icon: Icons.not_interested,
            onPressed: (context) => _setStatus(PointStatus.none),
          ),
        ],
      ),
      child: InkWell(
        onTap: openStatusSelector,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        child: Card(
          elevation: 1,
          shadowColor: FColors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.md,
                ),
                child: Row(
                  children: [
                    if (_point.status != PointStatus.note)
                      Text(
                        _point.status.toString(),
                        style: Theme.of(context).textTheme.titleMedium?.apply(
                          color: _point.status.color(),
                          fontWeightDelta: 2,
                        ),
                      ),
                    if (_point.status != PointStatus.note)
                      const SizedBox(width: FSizes.sm),
                    Expanded(
                      child: Text(
                        _point.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Icon(
                      _point.status.icon(),
                      color: _point.status.color(),
                      size: 22,
                    ),
                  ],
                ),
              ),
              if (_point.status == PointStatus.note)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: FSizes.sm,
                    horizontal: FSizes.md,
                  ),
                  decoration: BoxDecoration(
                    color: FColors.warning.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(FSizes.borderRadiusLg),
                      bottomRight: Radius.circular(FSizes.borderRadiusLg),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _point.status.icon(),
                        color: _point.status.color(),
                        size: 18,
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: Text(
                          _point.note ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.apply(
                            color: FColors.darkerGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setStatus(PointStatus status) async {
    Point newStatePoint = _point;
    try {
      if (status == PointStatus.note) {
        newStatePoint =
            await Get.dialog<Point>(
              InspectionNotesDialog(_point),
              barrierDismissible: false,
            ) ??
            _point;
      }
      newStatePoint.setStatus = status;
      setState(() {
        _point = newStatePoint;
      });
    } catch (e) {
      dd(e.toString());
    } finally {
      await widget.onChange(newStatePoint, status);
    }
  }

  @override
  void didUpdateWidget(covariant PointCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.point != widget.point ||
        oldWidget.onChange != widget.onChange) {
      setState(() {
        _point = widget.point;
      });
    }
  }

  void openStatusSelector() async {
    final status = await Get.bottomSheet<PointStatus>(
      const StatusBottomSheet(),
      backgroundColor: FHelper.isDarkMode(context)
          ? FColors.dark
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );

    if (status != null) {
      await _setStatus(status);
    }
  }
}
