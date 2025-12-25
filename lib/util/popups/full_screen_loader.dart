import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FFullScreenLoader{
  static void openLoadingDialog({required Widget page}){
    showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (_) => PopScope(
          canPop: false,
          child: page
        ),
    );
  }

  static void openLoading(){
    FFullScreenLoader.openLoadingDialog(
      page: Center(
        child: Container(
          width: FDeviceUtils.getScreenWidth() * .3,
          height: FDeviceUtils.getScreenWidth() * .3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            color: FColors.white
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: FColors.primaryColor,
            )
          )
        )
      )
    );
  }

  static stopLoading(){
    try {
      Get.back();
    } catch (_) {
    }
  }
}