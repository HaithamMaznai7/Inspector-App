import 'package:fahis_inspector/core/constants/app_colors.dart';
import 'package:fahis_inspector/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

abstract class SnackbarService {
  static void success(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(
        context,
        message: message,
        title: title,
        duration: duration,
        color: FColors.success,
        icon: const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
      );

  static void error(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(
        context,
        message: message,
        title: title,
        duration: duration,
        color: FColors.error,
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 20),
      );

  static void warning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) =>
      _show(
        context,
        message: message,
        title: title,
        duration: duration,
        color: FColors.warning,
        icon: const Icon(Iconsax.warning_2, color: Colors.white, size: 20),
      );

  static void info(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(
        context,
        message: message,
        title: title,
        duration: duration,
        color: FColors.info,
        icon: const Icon(Iconsax.info_circle, color: Colors.white, size: 20),
      );

  static void _show(
    BuildContext context, {
    required String message,
    required Color color,
    required Duration duration,
    String? title,
    Widget? icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(
          horizontal: FSizes.sm,
          vertical: FSizes.sm,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(FSizes.borderRadiusSm)),
        ),
        content: Row(
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: FSizes.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null && title.isNotEmpty)
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: FSizes.fontSizeSm,
                      ),
                    ),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FSizes.fontSizeXs,
                    ),
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
