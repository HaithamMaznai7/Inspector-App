import 'package:fahis_inspector/features/inspection_obd/controller.dart';
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
          padding: const EdgeInsets.symmetric(vertical: 28),
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
                      width: 32,
                      height: 32,
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
                        size: 26,
                        color: FColors.primaryColor,
                      ),
                    ),
              const SizedBox(height: FSizes.sm),
              Text(
                InspectionPage.uploadObdReport.tr,
                style: TextStyle(
                  fontSize: 14,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: FColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(color: FColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: FColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Text(
              InspectionPage.obdFileName.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? FColors.light : FColors.dark,
              ),
              overflow: TextOverflow.ellipsis,
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
          // Delete
          _IconBtn(
            icon: Iconsax.trash,
            color: FColors.error,
            bg: FColors.error.withValues(alpha: 0.08),
            onTap: controller.deleteReport,
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
          // ── Title row with add button ──
          _CardTitle(
            icon: Iconsax.cpu,
            title: InspectionPage.obdCodesTitle.tr,
            isDark: isDark,
            trailing: GestureDetector(
              onTap: () => InspectionObdBinding().instance.onCreateEdit(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: FColors.primaryColor,
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.add, size: 15, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: FSizes.sm),
          Divider(
            height: 1,
            color: FColors.grey.withValues(alpha: isDark ? 0.15 : 0.4),
          ),
          const SizedBox(height: FSizes.sm),

          // ── List / states ──
          if (isLoading)
            _SkeletonList(isDark: isDark)
          else if (codes.isEmpty)
            _CodesEmpty(isDark: isDark)
          else
            ...codes.map((c) => OBDCodeCard(code: c)),
        ],
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
          Icon(
            Iconsax.cpu,
            size: 36,
            color: FColors.grey.withValues(alpha: 0.4),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            InspectionPage.obdNoCodesYet.tr,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: FColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            InspectionPage.optionalTag.tr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: FColors.grey.withValues(alpha: 0.6),
            ),
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
          height: 46,
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
    this.trailing,
  });

  final IconData icon;
  final String title;
  final bool isDark;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: FColors.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: FColors.primaryColor),
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
        if (trailing != null) trailing!,
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
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
