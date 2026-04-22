import 'package:fahis_inspector/services/offline_sync/offline_sync_service.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A thin animated banner shown at the top of any screen while
/// [OfflineSyncService] is actively flushing queued offline writes.
///
/// Rendered above the page content so it never obscures data.
/// Automatically hides when [OfflineSyncService.isSyncing] goes false.
class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSyncing = OfflineSyncService.instance.isSyncing.value;
      final pending = OfflineSyncService.instance.pendingCount.value;

      if (!isSyncing && pending == 0) return const SizedBox.shrink();

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isSyncing
            ? _SyncingBar(pending: pending)
            : const SizedBox.shrink(),
      );
    });
  }
}

class _SyncingBar extends StatelessWidget {
  final int pending;
  const _SyncingBar({required this.pending});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('syncing'),
      width: double.infinity,
      color: FColors.info.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: FColors.info,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pending > 0
                  ? '${'syncing_offline_changes'.tr} ($pending)'
                  : 'syncing_offline_changes'.tr,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: FColors.info,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
