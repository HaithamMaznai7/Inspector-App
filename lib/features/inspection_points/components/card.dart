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
        child: Card(
          color: isDark ? FColors.grey.withOpacity(.2) : FColors.grey,
          child: Padding(
            padding: _point.status == PointStatus.note
                ? const EdgeInsetsDirectional.only(top: FSizes.lg)
                : const EdgeInsets.all(FSizes.lg),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_point.status != PointStatus.note)
                      Text(
                        _point.status.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.apply(
                          color: _point.status.color(),
                        ),
                      ),
                    SizedBox(
                      width: 200,
                      child: Text(
                        _point.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    if (_point.status != PointStatus.note)
                      Icon(_point.status.icon(), color: _point.status.color()),
                  ],
                ),
                if (_point.status == PointStatus.note)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: FSizes.sm,
                      horizontal: FSizes.lg,
                    ),
                    decoration: BoxDecoration(
                      color: FColors.warning.withOpacity(.4),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _point.note ?? '',
                          style: Theme.of(context).textTheme.titleSmall?.apply(
                            color: isDark
                                ? _point.status.color()
                                : FColors.dark,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Icon(
                          _point.status.icon(),
                          color: _point.status.color(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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
      isScrollControlled: true,
      const StatusBottomSheet(),
      backgroundColor: FHelper.isDarkMode(context)
          ? FColors.dark
          : Colors.white,
    );

    if (status != null) {
      await _setStatus(status);
    }
  }
}
