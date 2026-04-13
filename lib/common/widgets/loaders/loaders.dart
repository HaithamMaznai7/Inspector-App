import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/common/widgets/loaders/snackbar_queue.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import '../../../util/constants/colors.dart';
import '../../../util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FLoader {
  static void successSnackBar({String? title, String? message, duration = 3}) {
    SnackbarQueue.show(() {
      _snackBar(
        title: title,
        message: message,
        duration: duration,
        color: FColors.success,
        icon: const Icon(Iconsax.check, color: FColors.white),
      );
    }, duration: 1);
  }

  static void warningSnackBar({String? title, String? message, duration = 3}) {
    // SnackbarQueue.show(() {
    _snackBar(
      title: title,
      message: message,
      duration: duration,
      color: FColors.warning,
      icon: const Icon(Iconsax.warning_2, color: FColors.white),
    );
    // }, duration: 1);
  }

  static void errorSnackBar({String? title, String? message, duration = 3}) {
    SnackbarQueue.show(() {
      _snackBar(
        title: title,
        message: message,
        duration: duration,
        color: FColors.error,
        icon: const Icon(Icons.error, color: FColors.white),
      );
    }, duration: 1);
  }

  static void infoSnackBar({String? title, String? message, duration = 3}) {
    SnackbarQueue.show(() {
      _snackBar(
        title: title,
        message: message,
        duration: duration,
        color: FColors.info,
        icon: const Icon(Iconsax.info_circle, color: FColors.white),
      );
    }, duration: 1);
  }

  static void notification({
    String? title,
    String? message,
    duration = 3,
    String? image,
  }) {
    AppLogger.trace('FLoader', 'push notification snackbar queued: "$title"');
    SnackbarQueue.show(() {
      _snackBar(
        title: title,
        message: message,
        duration: duration,
        color: FColors.buttonDisable,
        image: image,
      );
    }, duration: 1);
  }

  /// Shows a non-dismissible full-screen logout loading overlay.
  /// Navigation (Get.offAllNamed) dismisses it automatically when done.
  static void showLogoutLoading() {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      const _LogoutLoadingDialog(),
      barrierDismissible: false,
      barrierColor: Colors.black54,
    );
  }

  static void _snackBar({
    String? title,
    String? message,
    duration = 3,
    required Color color,
    Widget? icon,
    String? image,
  }) {
    void showSnackbar() {
      try {
        Get.snackbar(
          title ?? '',
          message ?? '',
          isDismissible: true,
          shouldIconPulse: true,
          titleText: title == null ? const SizedBox() : null,
          messageText: message == null ? const SizedBox() : null,
          margin: const EdgeInsets.symmetric(
            horizontal: FSizes.sm,
            vertical: FSizes.sm,
          ),
          borderRadius: FSizes.borderRadiusSm,
          colorText: FColors.white,
          backgroundColor: color,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: duration),
          icon: image != null
              ? CachedNetworkImage(
                  imageUrl: image,
                  width: FSizes.iconCircleSm,
                  height: FSizes.iconCircleSm,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const SizedBox.shrink(),
                  errorWidget: (_, _, _) => const SizedBox.shrink(),
                )
              : icon,
          snackStyle: SnackStyle.FLOATING,
        );
      } catch (e) {
        dd(e.toString());
      }
    }

    if (Get.key.currentState?.overlay != null) {
      showSnackbar();
    } else {
      // Defer to next frame when the overlay should be available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar();
      });
    }
  }
}

// ── Logout loading dialog ──────────────────────────────────────────────────────

class _LogoutLoadingDialog extends StatelessWidget {
  const _LogoutLoadingDialog();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final subtitleColor = isDark
        ? FColors.grey.withValues(alpha: 0.7)
        : FColors.darkGrey;

    // Responsive card width: compact on phones, slightly wider on tablets.
    final cardWidth = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 240,
      tablet: 280,
      desktop: 300,
    );
    final spinnerSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: FSizes.iconCircleLg,
      tablet: FSizes.iconCircleLg + FSizes.sm,
      desktop: FSizes.iconXl,
    );
    final titleSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: FSizes.fontSizeMd,
      tablet: FSizes.fontSizeLg,
      desktop: 19,
    );
    final subtitleSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 13,
      tablet: FSizes.fontSizeSm,
      desktop: 15,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.xl,
          vertical: FSizes.spaceBtwSections,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Branded spinner with a subtle track
            SizedBox(
              width: spinnerSize,
              height: spinnerSize,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: const AlwaysStoppedAnimation(FColors.primaryColor),
                backgroundColor: FColors.primaryColor.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: FSizes.defaultSpace),

            // Title
            Text(
              FTexts.loggingOutTitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: isDark ? FColors.light : FColors.dark,
                height: 1.2,
              ),
            ),
            const SizedBox(height: FSizes.sm),

            // Subtitle
            Text(
              FTexts.loggingOutSubtitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: subtitleSize,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
