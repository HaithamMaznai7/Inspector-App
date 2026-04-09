import 'package:fahis_inspector/features/paint_gauge/components/current_reading_panel.dart';
import 'package:fahis_inspector/features/paint_gauge/components/panel_list.dart';
import 'package:fahis_inspector/features/paint_gauge/components/scan_view.dart';
import 'package:fahis_inspector/features/paint_gauge/components/status_card.dart';
import 'package:fahis_inspector/features/paint_gauge/controller.dart';
import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PaintGaugeStepView extends StatelessWidget {
  const PaintGaugeStepView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaintGaugeController>(
      tag: BindingTags.paintGauge,
      init: PaintGaugeBinding().instance,
      autoRemove: false,
      builder: (controller) {
        return Obx(() {
          // Show loading only when no cached panels yet
          if (controller.isPanelsLoading.value &&
              controller.isPanelsEmpty) {
            return Center(
              child: CircularProgressIndicator(color: FColors.primaryColor),
            );
          }
          return _PaintGaugeBody(controller: controller);
        });
      },
    );
  }
}

// ── Main body — always shows panel list, BLE is additive ──────────────────────

class _PaintGaugeBody extends StatefulWidget {
  final PaintGaugeController controller;
  const _PaintGaugeBody({required this.controller});

  @override
  State<_PaintGaugeBody> createState() => _PaintGaugeBodyState();
}

class _PaintGaugeBodyState extends State<_PaintGaugeBody> {
  Worker? _panelWorker;

  final Map<CarPart, GlobalKey> _panelKeys = {
    for (final part in CarPart.values) part: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _panelWorker = ever(widget.controller.currentDevicePanel, _scrollToPanel);
  }

  @override
  void dispose() {
    _panelWorker?.dispose();
    super.dispose();
  }

  void _scrollToPanel(CarPart? part) {
    if (part == null) return;
    final key = _panelKeys[part];
    final ctx = key?.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }

  void _showScanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(FSizes.borderRadiusLg),
        ),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag handle
              Container(
                width: FSizes.xl,
                height: FSizes.xs,
                margin: const EdgeInsets.symmetric(vertical: FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.darkGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(FSizes.xs / 2),
                ),
              ),
              const Expanded(child: PaintGaugeScanView()),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connected = widget.controller.isConnected.value;
      final connecting = widget.controller.isConnecting.value;

      return Stack(
        children: [
          // Always visible: panel list with backend data
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (connected)
                ConnectionStatusCard(controller: widget.controller),
              if (connected)
                CurrentReadingPanel(controller: widget.controller),
              Expanded(
                child: ListView(
                  children: [
                    if (connected)
                      _ClearAllButton(controller: widget.controller),
                    PanelListWidget(
                      controller: widget.controller,
                      panelKeys: _panelKeys,
                    ),
                    // Space for FAB
                    const SizedBox(height: FSizes.xl * 2.5),
                  ],
                ),
              ),
            ],
          ),

          // FAB: Connect Device (when not connected and not connecting)
          if (!connected && !connecting)
            Positioned(
              bottom: FSizes.md,
              right: FSizes.md,
              left: FSizes.md,
              child: SafeArea(
                child: FloatingActionButton.extended(
                  onPressed: _showScanSheet,
                  backgroundColor: FColors.primaryColor,
                  foregroundColor: FColors.white,
                  icon: const Icon(Iconsax.bluetooth),
                  label: Text(
                    PaintGaugePage.scanButton.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

          // Connecting overlay (lightweight, non-blocking)
          if (connecting)
            _ConnectingOverlay(controller: widget.controller),
        ],
      );
    });
  }
}

// ── Connecting overlay ────────────────────────────────────────────────────────

class _ConnectingOverlay extends StatelessWidget {
  final PaintGaugeController controller;
  const _ConnectingOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(FSizes.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: FSizes.buttonHeightLg,
                  height: FSizes.buttonHeightLg,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: FColors.primaryColor,
                  ),
                ),
                const SizedBox(height: FSizes.lg),
                Text(
                  PaintGaugePage.connecting.tr,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  PaintGaugePage.sessionReadingsOnly.tr,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: FColors.darkGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Clear all button ──────────────────────────────────────────────────────────

class _ClearAllButton extends StatelessWidget {
  final PaintGaugeController controller;
  const _ClearAllButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.measuredPanelCount == 0) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: () => _confirmClearAll(context),
            icon: const Icon(Icons.clear_all, size: FSizes.fontSizeLg),
            label: Text(PaintGaugePage.clearAll.tr),
            style: TextButton.styleFrom(
              foregroundColor: FColors.error,
              textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(PaintGaugePage.clearAll.tr),
        content: Text(PaintGaugePage.clearAllConfirm.tr),
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
      await controller.clearAllPanels();
    }
  }
}
