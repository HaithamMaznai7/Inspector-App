import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/enums/body_part.dart';
import 'package:fahis_inspector/features/paint_gauge/components/panel_mapping.dart';
import 'package:fahis_inspector/features/paint_gauge/controller.dart';
import 'package:fahis_inspector/models/inspection_body_notes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarIllustrationWidget extends StatelessWidget {
  final PaintGaugeController controller;

  const CarIllustrationWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaintGaugeController>(
      tag: 'PaintGauge',
      builder: (_) {
        final bodies = controller.carBodies;

        final topBody = bodies.firstWhereOrNull((b) => b.part == BodyPart.top);
        final leftBody =
            bodies.firstWhereOrNull((b) => b.part == BodyPart.left);
        final rightBody =
            bodies.firstWhereOrNull((b) => b.part == BodyPart.right);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top view (full width)
              if (topBody != null)
                _CarView(
                  body: topBody,
                  view: CarView.top,
                  aspectRatio: 300 / 250,
                  controller: controller,
                ),

              if (topBody != null &&
                  (leftBody != null || rightBody != null))
                const SizedBox(height: FSizes.xs),

              // Left + Right views side by side
              if (leftBody != null || rightBody != null)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (leftBody != null)
                        Expanded(
                          child: _CarView(
                            body: leftBody,
                            view: CarView.left,
                            aspectRatio: 600 / 125,
                            controller: controller,
                          ),
                        ),
                      if (leftBody != null && rightBody != null)
                        const SizedBox(width: FSizes.xs),
                      if (rightBody != null)
                        Expanded(
                          child: _CarView(
                            body: rightBody,
                            view: CarView.right,
                            aspectRatio: 600 / 125,
                            controller: controller,
                          ),
                        ),
                    ],
                  ),
                ),

              // Placeholder when no images yet
              if (bodies.isEmpty) _buildPlaceholder(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: FColors.primaryColor,
          ),
        ),
      ),
    );
  }
}

class _CarView extends StatelessWidget {
  final CarBody body;
  final CarView view;
  final double aspectRatio;
  final PaintGaugeController controller;

  const _CarView({
    required this.body,
    required this.view,
    required this.aspectRatio,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final regions = panelsForView(view);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return ClipRRect(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            child: Stack(
              children: [
                // Background car image
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: body.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Theme.of(context)
                          .dividerColor
                          .withValues(alpha: 0.2),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Theme.of(context)
                          .dividerColor
                          .withValues(alpha: 0.2),
                      child: const Icon(Icons.image_not_supported,
                          color: FColors.darkGrey),
                    ),
                  ),
                ),

                // Panel overlay regions
                ...regions.map((region) => _PanelOverlay(
                      region: region,
                      controller: controller,
                      viewWidth: w,
                      viewHeight: h,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PanelOverlay extends StatelessWidget {
  final PanelRegion region;
  final PaintGaugeController controller;
  final double viewWidth;
  final double viewHeight;

  const _PanelOverlay({
    required this.region,
    required this.controller,
    required this.viewWidth,
    required this.viewHeight,
  });

  Color _fillColor(BuildContext context) {
    final part = region.part;
    if (controller.panelIsSelected(part) ||
        controller.panelIsActiveOnDevice(part)) {
      return FColors.primaryColor.withValues(alpha: 0.35);
    }
    if (controller.panelIsComplete(part)) {
      return FColors.primaryColor.withValues(alpha: 0.25);
    }
    if (controller.panelIsPartial(part)) {
      return FColors.darkGrey.withValues(alpha: 0.25);
    }
    return Colors.transparent;
  }

  Color _borderColor(BuildContext context) {
    final part = region.part;
    if (controller.panelIsSelected(part) ||
        controller.panelIsActiveOnDevice(part)) {
      return FColors.primaryColor;
    }
    if (controller.panelIsComplete(part)) {
      return FColors.primaryColor.withValues(alpha: 0.6);
    }
    if (controller.panelIsPartial(part)) {
      return FColors.darkGrey.withValues(alpha: 0.5);
    }
    return FColors.darkGrey.withValues(alpha: 0.2);
  }

  double _borderWidth() {
    final part = region.part;
    if (controller.panelIsSelected(part) ||
        controller.panelIsActiveOnDevice(part)) {
      return 1.5;
    }
    return 0.8;
  }

  @override
  Widget build(BuildContext context) {
    final left = viewWidth * region.left / 100;
    final top = viewHeight * region.top / 100;
    final width = viewWidth * region.width / 100;
    final height = viewHeight * region.height / 100;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => controller.selectPanel(region.part),
        child: Container(
          decoration: BoxDecoration(
            color: _fillColor(context),
            border: Border.all(
              color: _borderColor(context),
              width: _borderWidth(),
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
