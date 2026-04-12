import 'dart:io';

import 'package:fahis_inspector/common/widgets/camera/camera.dart';
import 'package:fahis_inspector/common/widgets/camera/image_quality_checker.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

const String _tag = 'ImageSourcePicker';

enum _ImageSource { camera, gallery }

/// Shows a platform-adaptive bottom sheet to choose between Camera and Gallery,
/// then captures/picks and compresses the image before returning.
class ImageSourcePicker {
  ImageSourcePicker._();

  static Future<File?> pick() async {
    final isIOS = GetPlatform.isIOS;

    final source = isIOS ? await _showIOSPicker() : await _showAndroidPicker();
    if (source == null) return null;

    File? file;
    if (source == _ImageSource.camera) {
      file = await Camera.open();
    } else {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) file = File(picked.path);
    }

    if (file == null) return null;

    AppLogger.trace(_tag, 'Compressing ${source.name} image', {
      'originalKB': (file.lengthSync() / 1024).toStringAsFixed(0),
    });

    final compressed = await ImageCompressor.compress(file);

    AppLogger.info(_tag, 'Image ready', {
      'source': source.name,
      'compressedKB': (compressed.lengthSync() / 1024).toStringAsFixed(0),
    });

    return compressed;
  }

  // ── iOS: CupertinoActionSheet ────────────────────────────────────────────

  static Future<_ImageSource?> _showIOSPicker() async {
    return showCupertinoModalPopup<_ImageSource>(
      context: Get.context!,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, _ImageSource.camera),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.camera, size: 22),
                const SizedBox(width: FSizes.sm),
                Text(FTexts.imageSourceCamera.tr),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, _ImageSource.gallery),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.photo, size: 22),
                const SizedBox(width: FSizes.sm),
                Text(FTexts.imageSourceGallery.tr),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ),
    );
  }

  // ── Android: Material Bottom Sheet ──────────────────────────────────────

  static Future<_ImageSource?> _showAndroidPicker() async {
    return showModalBottomSheet<_ImageSource>(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? FColors.dark : Colors.white;

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                FSizes.lg,
                FSizes.sm,
                FSizes.lg,
                FSizes.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: FSizes.sm),

                  // Camera option
                  _SourceTile(
                    icon: Icons.camera_alt_outlined,
                    label: FTexts.imageSourceCamera.tr,
                    onTap: () => Navigator.pop(context, _ImageSource.camera),
                  ),
                  const SizedBox(height: FSizes.sm),

                  // Gallery option
                  _SourceTile(
                    icon: Icons.photo_library_outlined,
                    label: FTexts.imageSourceGallery.tr,
                    onTap: () => Navigator.pop(context, _ImageSource.gallery),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tappable row for Android material bottom sheet.
class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FColors.primaryColor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: FColors.primaryColor, size: 22),
              ),
              const SizedBox(width: FSizes.md),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: FColors.darkGrey.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
