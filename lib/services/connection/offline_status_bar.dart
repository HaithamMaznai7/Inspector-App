import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
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
      return Container(
        width: double.infinity,
        color: FColors.darkGrey,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'offline_bar_message'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}
