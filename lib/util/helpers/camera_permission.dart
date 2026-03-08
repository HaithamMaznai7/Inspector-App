import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/text_strings.dart';
import 'package:flutter/material.dart';

class CameraPermissionHelper {
  /// Requests camera permission. Returns true if granted.
  /// On first denial shows a retry dialog; on permanent denial shows a settings dialog.
  static Future<bool> requestCamera() => _request(Permission.camera);

  /// Requests photo library permission. Returns true if granted.
  static Future<bool> requestPhotos() => _request(Permission.photos);

  static Future<bool> _request(Permission permission) async {
    var status = await permission.status;

    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog();
      return false;
    }

    status = await permission.request();

    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog();
      return false;
    }

    // Denied — offer one retry
    return await _showRetryDialog(permission);
  }

  static Future<bool> _showRetryDialog(Permission permission) async {
    final retry = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Permission Required'.tr),
        content: Text(
          'You must to give a permission to can use camera or select image from gallery'
              .tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(FTexts.cancelBtn.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );

    if (retry != true) return false;

    final status = await permission.request();
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog();
    }

    return false;
  }

  static Future<void> _showSettingsDialog() async {
    final goToSettings = await Get.dialog<bool>(
      AlertDialog(
        title: Text('No Permission'.tr),
        content: Text(
          'You must to give a permission to can use camera or select image from gallery'
              .tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(FTexts.cancelBtn.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Go to settings'.tr),
          ),
        ],
      ),
    );

    if (goToSettings == true) await openAppSettings();
  }
}
