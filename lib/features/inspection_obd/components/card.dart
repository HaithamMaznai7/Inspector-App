import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

class OBDCodeCard extends StatefulWidget {
  final OBDCode code;
  /// True when the code was saved locally but hasn't been POSTed to the server.
  final bool isPendingSync;
  /// True when the code was added by reading from a BLE OBD device this session.
  final bool isFromDevice;

  const OBDCodeCard({
    super.key,
    required this.code,
    this.isPendingSync = false,
    this.isFromDevice = false,
  });

  @override
  State<OBDCodeCard> createState() => _OBDCodeCardState();
}

class _OBDCodeCardState extends State<OBDCodeCard> {
  bool _isDeleting = false;

  /// True when the inspector still owes a description for a code that came
  /// from the BLE adapter. The dialog forbids empty descriptions on manual
  /// entries, so this only ever fires for device-sourced codes.
  bool get _needsDescription =>
      widget.isFromDevice && widget.code.description.trim().isEmpty;

  Future<void> _confirmDelete(BuildContext context, bool isDark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? FColors.dark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        title: Text(
          InspectionPage.deleteObdCode.tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? FColors.light : FColors.dark,
          ),
        ),
        content: Text(
          InspectionPage.deleteObdCodeConfirm.tr,
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
    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      await InspectionObdBinding().instance.delete(widget.code);
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    if (_isDeleting) {
      return _DeletingShimmer(isDark: isDark);
    }

    return InkWell(
      onTap: () =>
          InspectionObdBinding().instance.onCreateEdit(code: widget.code),
      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      child: Container(
        margin: const EdgeInsets.only(bottom: FSizes.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? FColors.darkGrey.withValues(alpha: 0.25)
              : FColors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: _needsDescription
                ? FColors.error
                : (isDark
                    ? FColors.grey.withValues(alpha: 0.12)
                    : FColors.grey.withValues(alpha: 0.25)),
            width: _needsDescription ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Code badge (+ device / pending-sync icons)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.sm,
                        vertical: FSizes.borderRadiusSm,
                      ),
                      decoration: BoxDecoration(
                        color: FColors.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          FSizes.borderRadiusMd,
                        ),
                        border: Border.all(
                          color: FColors.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        widget.code.code,
                        style: const TextStyle(
                          fontSize: FSizes.fontSizeXs,
                          fontWeight: FontWeight.w700,
                          color: FColors.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (widget.isFromDevice) ...[
                      const SizedBox(width: FSizes.xs),
                      Tooltip(
                        message: InspectionPage.obdFromDevice.tr,
                        child: const Icon(
                          Iconsax.bluetooth,
                          size: FSizes.fontSizeSm,
                          color: FColors.primaryColor,
                        ),
                      ),
                    ],
                    if (widget.isPendingSync) ...[
                      const SizedBox(width: FSizes.xs),
                      const Tooltip(
                        message: 'Pending sync',
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: FSizes.fontSizeSm,
                          color: FColors.primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: FSizes.sm),
                // Description (or italic placeholder when missing)
                Expanded(
                  child: Text(
                    _needsDescription
                        ? 'obd_card_tap_to_describe'.tr
                        : widget.code.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: _needsDescription
                          ? FontWeight.w400
                          : FontWeight.w500,
                      fontStyle: _needsDescription
                          ? FontStyle.italic
                          : FontStyle.normal,
                      color: _needsDescription
                          ? (isDark ? FColors.grey : FColors.darkGrey)
                          : (isDark ? FColors.light : FColors.dark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: FSizes.xs),
                // Delete button
                GestureDetector(
                  onTap: () => _confirmDelete(context, isDark),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.xs),
                    decoration: BoxDecoration(
                      color: FColors.error.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.trash,
                      size: FSizes.iconXs,
                      color: FColors.error,
                    ),
                  ),
                ),
              ],
            ),
            if (_needsDescription) ...[
              const SizedBox(height: FSizes.xs),
              Row(
                children: [
                  const Icon(
                    Iconsax.warning_2,
                    size: FSizes.fontSizeSm,
                    color: FColors.error,
                  ),
                  const SizedBox(width: FSizes.xs),
                  Expanded(
                    child: Text(
                      'obd_card_description_required'.tr,
                      style: const TextStyle(
                        fontSize: FSizes.fontSizeXs,
                        fontWeight: FontWeight.w600,
                        color: FColors.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeletingShimmer extends StatelessWidget {
  const _DeletingShimmer({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? FColors.darkGrey : Colors.grey[300]!;
    final highlight = isDark
        ? FColors.grey.withValues(alpha: 0.15)
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: FSizes.xs),
        height: 48,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
      ),
    );
  }
}
