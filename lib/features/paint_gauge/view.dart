import 'package:fahis_inspector/features/paint_gauge/components/car_illustration.dart';
import 'package:fahis_inspector/features/paint_gauge/components/panel_list.dart';
import 'package:fahis_inspector/features/paint_gauge/components/scan_view.dart';
import 'package:fahis_inspector/features/paint_gauge/components/status_card.dart';
import 'package:fahis_inspector/features/paint_gauge/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
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
          if (!controller.isConnected.value) {
            return _ScanShell(controller: controller);
          }
          return _MeasurementView(controller: controller);
        });
      },
    );
  }
}

// ── Scan shell ─────────────────────────────────────────────────────────────────

class _ScanShell extends StatelessWidget {
  final PaintGaugeController controller;
  const _ScanShell({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isConnecting = controller.isConnecting.value;

      if (isConnecting) {
        return _ConnectingOverlay(controller: controller);
      }

      return Column(
        children: [
          Expanded(child: PaintGaugeScanView()),
          _SkipButton(),
        ],
      );
    });
  }
}

class _ConnectingOverlay extends StatelessWidget {
  final PaintGaugeController controller;
  const _ConnectingOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: FColors.primaryColor,
              ),
            ),
            const SizedBox(height: FSizes.lg),
            Text(
              PaintGaugePage.connecting.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              PaintGaugePage.sessionReadingsOnly.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FColors.darkGrey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(FSizes.md, 0, FSizes.md, FSizes.md),
      child: TextButton(
        onPressed: () {
          // The step is skippable — the inspection steps controller handles
          // canAdvanceFromCurrentStep = true for this tab
        },
        child: Text(
          PaintGaugePage.skipStep.tr,
          style: const TextStyle(color: FColors.darkGrey),
        ),
      ),
    );
  }
}

// ── Measurement view ────────────────────────────────────────────────────────────

class _MeasurementView extends StatelessWidget {
  final PaintGaugeController controller;
  const _MeasurementView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConnectionStatusCard(controller: controller),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: FSizes.sm),
              CarIllustrationWidget(controller: controller),
              const SizedBox(height: FSizes.md),
              _ClearAllButton(controller: controller),
              const SizedBox(height: FSizes.xs),
              PanelListWidget(controller: controller),
              const SizedBox(height: FSizes.lg),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClearAllButton extends StatelessWidget {
  final PaintGaugeController controller;
  const _ClearAllButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.measuredPanelCount == 0) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: () => _confirmClearAll(context),
            icon: const Icon(Icons.clear_all, size: 18),
            label: Text(PaintGaugePage.clearAll.tr),
            style: TextButton.styleFrom(
              foregroundColor: FColors.error,
              textStyle: const TextStyle(fontSize: 13),
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
