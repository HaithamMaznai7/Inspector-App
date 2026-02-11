import 'package:fahis_inspector/common/widgets/loaders/snackbar_queue.dart';
import 'package:fahis_inspector/main.dart';

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

  // WHAT: Show a styled snackbar notification at the top of the screen.
  // WHY: The original code crashed with "No Overlay widget found" because
  //      Get.snackbar was called before the widget tree was fully built
  //      (e.g., during navigation transitions or early controller lifecycle).
  // HOW: We check if the overlay is available before showing the snackbar.
  //      If the overlay isn't ready yet, we defer the snackbar to the next frame
  //      using WidgetsBinding.addPostFrameCallback, giving the widget tree
  //      time to fully build and mount the Overlay.
  // EDGE CASES:
  //   - Called during navigation transition → deferred to next frame
  //   - Called after dispose → caught by try/catch, logged silently
  //   - Multiple snackbars queued → SnackbarQueue handles sequencing
  // PERFORMANCE: addPostFrameCallback adds negligible overhead (one frame delay).
  static _snackBar({
    String? title,
    String? message,
    duration = 3,
    required Color color,
    Widget? icon,
    String? image,
  }) {
    // Helper that actually calls Get.snackbar
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
          icon: image != null ? Image.network(image) : icon,
          snackStyle: SnackStyle.FLOATING,
        );
      } catch (e) {
        // WHAT: Silently catch any remaining overlay or context errors.
        // WHY: Even with the deferred approach, edge cases (e.g., app backgrounded)
        //      could still cause failures. We never want a snackbar to crash the app.
        dd(e.toString());
      }
    }

    // WHAT: Check if the overlay is available before showing the snackbar.
    // WHY: During navigation transitions, the Overlay widget may not be
    //      mounted yet. Calling Get.snackbar at that moment causes
    //      "No Overlay widget found" crash.
    // HOW: We check if Get.key.currentState?.overlay is non-null.
    //      If not available, we defer to the next frame.
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
