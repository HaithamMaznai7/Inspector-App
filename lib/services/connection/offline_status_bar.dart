import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A thin, non-blocking bar displayed below the AppBar whenever the device
/// is offline AND the user has previously loaded data (so they can keep
/// working with cached content). The bar disappears automatically when
/// connectivity is restored.
class OfflineStatusBar extends StatelessWidget {
  const OfflineStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final service = ConnectionService.instance;
      // Only show after the user has been online at least once (has cached data).
      // On initial boot with no cache the full-screen OfflineScreen is used instead.
      if (service.isConnectionGood.value || !service.hasEverBeenOnline) {
        return const SizedBox.shrink();
      }
      return Material(
        color: FColors.error,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: FSizes.xs, horizontal: FSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: FSizes.iconSm, color: FColors.white),
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
