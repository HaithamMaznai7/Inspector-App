import 'package:fahis_inspector/features/inspection_obd/controller.dart';
import 'package:fahis_inspector/features/inspection_obd/components/ble_status_card.dart';
import 'package:fahis_inspector/features/inspection_obd/components/card.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class OBDCodesView extends StatelessWidget {
  const OBDCodesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return GetBuilder<InspectionObdController>(
      init: InspectionObdBinding().instance,
      autoRemove: false,
      builder: (controller) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReportCard(controller: controller, isDark: isDark),
              const SizedBox(height: FSizes.md),
              _CodesCard(controller: controller, isDark: isDark),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Report card
// ─────────────────────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.controller, required this.isDark});

  final InspectionObdController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasReport = controller.report.value != null;
    final isUploading = controller.isUpload.value;

    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ──
          _CardTitle(
            icon: Iconsax.document_upload,
            title: InspectionPage.uploadObdReport.tr,
            isDark: isDark,
          ),
          const SizedBox(height: FSizes.md),

          // ── Content ──
          hasReport
              ? _ReportUploaded(controller: controller, isDark: isDark)
              : _ReportEmpty(
                  controller: controller,
                  isDark: isDark,
                  isUploading: isUploading,
                ),
        ],
      ),
    );
  }
}

class _ReportEmpty extends StatelessWidget {
  const _ReportEmpty({
    required this.controller,
    required this.isDark,
    required this.isUploading,
  });

  final InspectionObdController controller;
  final bool isDark;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : controller.pickReport,
      child: AnimatedOpacity(
        opacity: isUploading ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: FSizes.lg),
          decoration: BoxDecoration(
            color: isDark
                ? FColors.darkGrey.withValues(alpha: 0.2)
                : FColors.primaryColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            border: Border.all(
              color: FColors.primaryColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              isUploading
                  ? const SizedBox(
                      width: FSizes.xl,
                      height: FSizes.xl,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: FColors.primaryColor,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: FColors.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.document_upload,
                        size: FSizes.iconMd,
                        color: FColors.primaryColor,
                      ),
                    ),
              const SizedBox(height: FSizes.sm),
              Text(
                InspectionPage.uploadObdReport.tr,
                style: TextStyle(
                  fontSize: FSizes.fontSizeSm,
                  fontWeight: FontWeight.w600,
                  color: FColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportUploaded extends StatelessWidget {
  const _ReportUploaded({required this.controller, required this.isDark});

  final InspectionObdController controller;
  final bool isDark;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? FColors.dark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        title: Text(
          InspectionPage.obdDeleteReportTitle.tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? FColors.light : FColors.dark,
          ),
        ),
        content: Text(
          InspectionPage.obdDeleteReportConfirm.tr,
          style: TextStyle(
            color: isDark ? FColors.grey : FColors.darkGrey,
            fontSize: FSizes.fontSizeSm,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              FTexts.cancelBtn.tr,
              style: const TextStyle(color: FColors.darkGrey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              FTexts.deleteBtn.tr,
              style: const TextStyle(
                color: FColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = controller.hasPendingReport;
    final accent = isPending ? FColors.warning : FColors.success;

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending ? Iconsax.cloud_minus : Icons.check_circle_rounded,
              color: accent,
              size: FSizes.iconInlineSm,
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  InspectionPage.obdFileName.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? FColors.light : FColors.dark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (isPending) ...[
                  const SizedBox(height: 2),
                  Text(
                    'saved_locally_will_sync'.tr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: FSizes.xs),
          // View
          _IconBtn(
            icon: Iconsax.eye,
            color: FColors.primaryColor,
            bg: FColors.primaryColor.withValues(alpha: 0.1),
            onTap: controller.openReport,
          ),
          const SizedBox(width: FSizes.xs),
          // Delete — requires confirmation
          _IconBtn(
            icon: Iconsax.trash,
            color: FColors.error,
            bg: FColors.error.withValues(alpha: 0.08),
            onTap: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Codes card
// ─────────────────────────────────────────────────────────────────────────────

class _CodesCard extends StatelessWidget {
  const _CodesCard({required this.controller, required this.isDark});

  final InspectionObdController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final codes = controller.codes.toList();
    final isLoading = controller.isLoading.value;

    return _Card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Title row (no inline + button — both input paths live below) ──
          _CardTitle(
            icon: Iconsax.cpu,
            title: InspectionPage.obdCodesTitle.tr,
            isDark: isDark,
          ),

          const SizedBox(height: FSizes.sm),
          Divider(
            height: 1,
            color: FColors.grey.withValues(alpha: isDark ? 0.15 : 0.4),
          ),
          const SizedBox(height: FSizes.sm),

          // ── Two peer-level input paths ──
          BleStatusCard(controller: controller),
          const SizedBox(height: FSizes.xs),
          _AddManuallyButton(
            onTap: () => InspectionObdBinding().instance.onCreateEdit(),
          ),
          const SizedBox(height: FSizes.sm),

          // ── List / states ──
          if (isLoading)
            _SkeletonList(isDark: isDark)
          else if (codes.isEmpty)
            _CodesEmpty(isDark: isDark)
          else
            ...codes.map((c) => OBDCodeCard(
              code: c,
              isPendingSync: controller.hasPendingCode(c.code),
              isFromDevice: controller.isBleSourced(c.code),
            )),
        ],
      ),
    );
  }
}

/// Full-width "Add Manually" button — peer to the BLE input path so the
/// inspector clearly sees both ways to add a code.
class _AddManuallyButton extends StatelessWidget {
  const _AddManuallyButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.sm,
          vertical: FSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? FColors.darkGrey.withValues(alpha: 0.15)
              : FColors.primaryColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
          border: Border.all(
            color: FColors.primaryColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Iconsax.edit,
              size: FSizes.iconInlineSm,
              color: FColors.primaryColor,
            ),
            const SizedBox(width: FSizes.sm),
            Expanded(
              child: Text(
                InspectionPage.obdAddManualCode.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? FColors.light : FColors.dark,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.sm,
                vertical: FSizes.xs,
              ),
              decoration: BoxDecoration(
                color: FColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                border: Border.all(
                  color: FColors.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.add,
                    size: FSizes.fontSizeSm,
                    color: FColors.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodesEmpty extends StatelessWidget {
  const _CodesEmpty({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FSizes.lg),
      child: Column(
        children: [
          Icon(Iconsax.cpu, size: FSizes.xl, color: FColors.darkGrey),
          const SizedBox(height: FSizes.sm),
          Text(
            InspectionPage.obdNoCodesYet.tr,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: FColors.darkGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? FColors.darkGrey.withValues(alpha: 0.4)
        : FColors.white.withValues(alpha: 0.02);

    return Column(
      children: List.generate(2, (i) {
        return Container(
          margin: const EdgeInsets.only(bottom: FSizes.xs),
          height: FSizes.buttonHeightSm,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared atoms
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: isDark ? FColors.darkContainer : FColors.lightContainer,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: isDark
              ? FColors.grey.withValues(alpha: 0.12)
              : FColors.darkGrey.withValues(alpha: 0.4),
        ),
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({
    required this.icon,
    required this.title,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(FSizes.xs),
          decoration: BoxDecoration(
            color: FColors.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: FSizes.iconXs, color: FColors.primaryColor),
        ),
        const SizedBox(width: FSizes.sm),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? FColors.light : FColors.dark,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(FSizes.xs),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: FSizes.iconSm, color: color),
      ),
    );
  }
}
