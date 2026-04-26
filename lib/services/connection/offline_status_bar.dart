import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A thin, non-blocking bar displayed below the AppBar whenever the device
/// is offline. Visible from the very first cold boot so the user always has
/// a clear connectivity signal even before any data has been cached.
/// Disappears automatically when connectivity is restored.
class OfflineStatusBar extends StatelessWidget {
  const OfflineStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final service = ConnectionService.instance;
      if (service.isConnectionGood.value) {
        return const SizedBox.shrink();
      }
      return Material(
        color: FColors.error,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: FSizes.md,
            horizontal: FSizes.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off,
                size: FSizes.iconSm,
                color: FColors.white,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'offline_bar_message'.tr,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: FColors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }
}
