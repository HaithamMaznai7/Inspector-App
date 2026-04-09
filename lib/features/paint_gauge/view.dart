import 'package:fahis_inspector/features/paint_gauge/components/current_reading_panel.dart';
import 'package:fahis_inspector/features/paint_gauge/components/panel_list.dart';
import 'package:fahis_inspector/features/paint_gauge/components/scan_view.dart';
import 'package:fahis_inspector/features/paint_gauge/components/status_card.dart';
import 'package:fahis_inspector/features/paint_gauge/controller.dart';
import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          if (controller.isPanelsLoading.value && controller.isPanelsEmpty) {
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

// ── Main body ─────────────────────────────────────────────────────────────────

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

    // Provide the navigate-to-scan callback so the controller can trigger it
    // without importing Flutter/view code.
    widget.controller.onNavigateToScan = _navigateToScan;
  }

  @override
  void dispose() {
    _panelWorker?.dispose();
    // Clear callback to avoid dangling reference after widget is removed.
    widget.controller.onNavigateToScan = null;
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

  void _navigateToScan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(FSizes.borderRadiusLg),
          ),
        ),
        child: const PaintGaugeScanView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status card — always visible; tappable when disconnected
        ConnectionStatusCard(
          controller: widget.controller,
          onConnectTap: widget.controller.startConnection,
        ),

        // Current reading panel — always visible
        CurrentReadingPanel(controller: widget.controller),

        // Panel list + clear-all
        Expanded(
          child: ListView(
            children: [
              // _ClearAllButton(controller: widget.controller),
              //TODO: Clearall button
              SizedBox(height: FSizes.md),
              PanelListWidget(
                controller: widget.controller,
                panelKeys: _panelKeys,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Clear all button ──────────────────────────────────────────────────────────

// class _ClearAllButton extends StatelessWidget {
//   final PaintGaugeController controller;
//   const _ClearAllButton({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (controller.measuredPanelCount == 0) return const SizedBox.shrink();

//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
//         child: Align(
//           alignment: AlignmentDirectional.centerEnd,
//           child: TextButton.icon(
//             onPressed: () => _confirmClearAll(context),
//             icon: const Icon(Icons.clear_all, size: FSizes.fontSizeLg),
//             label: Text(PaintGaugePage.clearAll.tr),
//             style: TextButton.styleFrom(
//               foregroundColor: FColors.error,
//               textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   Future<void> _confirmClearAll(BuildContext context) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(PaintGaugePage.clearAll.tr),
//         content: Text(PaintGaugePage.clearAllConfirm.tr),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text(FTexts.cancelBtn.tr),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text(
//               FTexts.deleteBtn.tr,
//               style: const TextStyle(color: FColors.error),
//             ),
//           ),
//         ],
//       ),
//     );
//     if (confirmed == true) {
//       await controller.clearAllPanels();
//     }
//   }
// }
