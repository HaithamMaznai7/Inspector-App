import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FLoader {

  static successSnackBar({String? title, String? message, duration = 3, }){
    _snackBar(
        title: title,
        message: message,
        duration: duration,
        color: FColors.success,
        icon: const Icon(Iconsax.check, color: FColors.white,)
    );
  }

  static warningSnackBar({String? title, String? message, duration = 3}){
    _snackBar(
        title: title,
        message: message,
        duration: duration,
        color: FColors.warning,
        icon: const Icon(Iconsax.warning_2, color: FColors.white,)
    );
  }

  static errorSnackBar({String? title, String? message, duration = 3, }){
    _snackBar(
        title: title,
        message: message,
        duration: duration,
        color: FColors.error,
        icon: const Icon(Icons.error, color: FColors.white,)
    );
  }

  static infoSnackBar({String? title, String? message, duration = 3}){
    _snackBar(
        title: title,
        message: message,
        duration: duration,
        color: FColors.info,
        icon: const Icon(Iconsax.info_circle, color: FColors.white,)
    );
  }

  static _snackBar({String? title, String? message, duration = 3, required Color color, Widget? icon}){
    try{

      Get.snackbar(
        title ?? '',
        message ?? '',
        isDismissible: true,
        shouldIconPulse: true,
        titleText: title == null ? const SizedBox() : null,
        messageText: message == null ? const SizedBox() : null,
        margin: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.sm),
        borderRadius: FSizes.borderRadiusSm,
        colorText: FColors.black,
        backgroundColor: color,
        snackPosition:  SnackPosition.TOP,
        duration: Duration(seconds: duration),
        icon: icon
      );
    }catch(_){}
  }
}