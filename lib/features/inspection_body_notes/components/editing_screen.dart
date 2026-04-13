import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/enums/body_part.dart';
import 'package:fahis_inspector/features/inspection_body_notes/controller.dart';
import 'package:fahis_inspector/models/inspection_body_notes.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionBodyTypeScreen extends StatefulWidget {
  final CarBody bodySide;

  const InspectionBodyTypeScreen({super.key, required this.bodySide});

  @override
  State<InspectionBodyTypeScreen> createState() =>
      _InspectionBodyTypeScreenState();
}

class _InspectionBodyTypeScreenState extends State<InspectionBodyTypeScreen> {
  double _imgW = 1;
  double _imgH = 1;
  TapDownDetails? _pendingTap;
  int? _draggingId;

  double _aspectRatio(BodyPart part) {
    if (part == BodyPart.right || part == BodyPart.left) return 600 / 125;
    if (part == BodyPart.interior) return 320 / 450;
    return 300 / 250;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FTexts.bodyInspectionDetails.tr,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.apply(color: FColors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: FColors.primaryGradient),
        ),
        iconTheme: const IconThemeData(color: FColors.white),
      ),
      body: GetBuilder<InspectionBodyController>(
        init: InspectionBodyBinding().instance,
        autoRemove: false,
        builder: (controller) {
          final match = controller.bodySides
              .where((b) => b.id == widget.bodySide.id);
          if (match.isEmpty) return const SizedBox();
          final body = match.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hint bar ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.sm,
                ),
                color: FColors.primaryColor.withValues(alpha: 0.06),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: FSizes.xs,
                  runSpacing: FSizes.xs,
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      size: FSizes.fontSizeSm,
                      color: FColors.primaryColor,
                    ),
                    Text(
                      FTexts.bodyTapHint.tr,
                      style: Theme.of(context).textTheme.bodySmall?.apply(
                            color: FColors.primaryColor,
                          ),
                    ),
                    const SizedBox(width: FSizes.xs),
                    const Icon(
                      Icons.open_with_rounded,
                      size: FSizes.fontSizeSm,
                      color: FColors.primaryColor,
                    ),
                    Text(
                      FTexts.bodyDragHint.tr,
                      style: Theme.of(context).textTheme.bodySmall?.apply(
                            color: FColors.primaryColor,
                          ),
                    ),
                  ],
                ),
              ),

              // ── Body diagram with markers ──
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(FSizes.md),
                    child: AspectRatio(
                      aspectRatio: _aspectRatio(body.part),
                      child: LayoutBuilder(
                        builder: (ctx, constraints) {
                          _imgW = constraints.maxWidth;
                          _imgH = constraints.maxHeight;
                          return GestureDetector(
                            onTapDown: (d) => _pendingTap = d,
                            onTap: () {
                              if (_pendingTap == null || _draggingId != null) {
                                _pendingTap = null;
                                return;
                              }
                              final dx =
                                  _pendingTap!.localPosition.dx / _imgW * 100;
                              final dy =
                                  _pendingTap!.localPosition.dy / _imgH * 100;
                              _pendingTap = null;
                              controller.onCreateEdit(
                                body,
                                Marker(id: 0, dx: dx, dy: dy),
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                // Body diagram image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      FSizes.borderRadiusMd),
                                  child: CachedNetworkImage(
                                    imageUrl: body.image,
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (_, __) => Container(
                                      decoration: BoxDecoration(
                                        color: FColors.grey
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(
                                            FSizes.borderRadiusMd),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: FColors.primaryColor,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color:
                                          FColors.grey.withValues(alpha: 0.08),
                                      child: const Center(
                                        child: Icon(Iconsax.image,
                                            color: FColors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                // Marker pins
                                ...body.notes.map(
                                  (note) => _buildMarker(
                                      controller, body, note),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // ── Note count footer ──
              if (body.notes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(
                          color: FColors.grey.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.note_1,
                          size: FSizes.fontSizeSm, color: FColors.primaryColor),
                      const SizedBox(width: FSizes.xs),
                      Text(
                        '${body.notes.length} ${FTexts.markerTitle.tr}',
                        style: Theme.of(context).textTheme.bodySmall?.apply(
                              color: FColors.primaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMarker(
    InspectionBodyController controller,
    CarBody body,
    Marker note,
  ) {
    final isDragging = _draggingId == note.id;
    // Pin is icon + padding total; center offset matches fontSizeLg
    const pinRadius = FSizes.fontSizeLg;

    return Positioned(
      left: (_imgW * note.dx / 100 - pinRadius).clamp(
          0, _imgW - pinRadius * 2),
      top: (_imgH * note.dy / 100 - pinRadius).clamp(
          0, _imgH - pinRadius * 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isDragging ? null : () => controller.onCreateEdit(body, note),
        onPanStart: (_) {
          _pendingTap = null; // cancel any pending tap-to-create
          setState(() => _draggingId = note.id);
        },
        onPanUpdate: (d) {
          setState(() {
            note.dx =
                (note.dx + d.delta.dx / _imgW * 100).clamp(0.0, 100.0);
            note.dy =
                (note.dy + d.delta.dy / _imgH * 100).clamp(0.0, 100.0);
          });
        },
        onPanEnd: (_) {
          setState(() => _draggingId = null);
          controller.onMoved(note);
        },
        child: AnimatedScale(
          scale: isDragging ? 1.25 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(FSizes.xs),
            decoration: BoxDecoration(
              color: isDragging
                  ? FColors.primaryColor.withValues(alpha: 0.28)
                  : FColors.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: FColors.primaryColor
                    .withValues(alpha: isDragging ? 0.9 : 0.5),
                width: isDragging ? 2 : 1.5,
              ),
              boxShadow: isDragging
                  ? [
                      BoxShadow(
                        color: FColors.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              Iconsax.warning_2,
              color: FColors.primaryColor,
              size: isDragging ? FSizes.iconMd : FSizes.iconInlineSm,
            ),
          ),
        ),
      ),
    );
  }
}
