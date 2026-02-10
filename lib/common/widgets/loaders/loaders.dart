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

  static _snackBar({
    String? title,
    String? message,
    duration = 3,
    required Color color,
    Widget? icon,
    String? image,
  }) {
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
      dd(e.toString());
    }
  }
}
