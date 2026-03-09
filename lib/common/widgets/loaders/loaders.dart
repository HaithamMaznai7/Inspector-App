import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/common/widgets/loaders/snackbar_queue.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import '../../../util/constants/colors.dart';
import '../../../util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FLoader {
  static successSnackBar({String? title, String? message, duration = 3}) {
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

  static warningSnackBar({String? title, String? message, duration = 3}) {
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

  static errorSnackBar({String? title, String? message, duration = 3}) {
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

  static infoSnackBar({String? title, String? message, duration = 3}) {
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

  static notification({
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

  static _snackBar({
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
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox.shrink(),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
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
