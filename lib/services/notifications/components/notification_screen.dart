import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/models/notification.dart' as model;
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/notifications/notifications_service.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? FColors.dark : FColors.softGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Notifications'.tr,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: BackPageButton(),
      ),
      body: GetBuilder<NotificationsService>(
        init: NotificationsBinding().instance,
        builder: (c) {
          if (c.isLoading.value) {
            return _buildLoading();
          }

          final notifications = c.notifications.toList();

          if (notifications.isEmpty) {
            return _buildEmpty(context, isDark);
          }

          return RefreshIndicator(
            onRefresh: c.onRefresh,
            color: FColors.primaryColor,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.sm,
              ),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () => c.onOpen(notification.id),
                  onToggleRead: () => notification.readAt == null
                      ? c.read(notification.id)
                      : c.unread(notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(color: FColors.primaryColor),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.notification_status,
              size: FSizes.iconXl,
              color: isDark ? FColors.grey : FColors.darkGrey,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'No notifications yet'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: FColors.darkerGrey,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'You will see your notifications here'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FColors.darkGrey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final model.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onToggleRead,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    final isUnread = notification.readAt == null;

    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: Material(
        color: isUnread
            ? (isDark ? FColors.darkerGrey : Colors.white)
            : (isDark ? FColors.dark : FColors.softGrey),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        elevation: isUnread ? 1 : 0,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: onTap,
          onLongPress: onToggleRead,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          child: Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              border: Border.all(
                color: isUnread
                    ? FColors.primaryColor.withValues(alpha: 0.15)
                    : FColors.grey.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(isUnread),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: FColors.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: FSizes.sm,
                              height: FSizes.sm,
                              margin: const EdgeInsetsDirectional.only(
                                  start: FSizes.sm),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: FColors.primaryColor,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: FSizes.xs),
                      Text(
                        notification.description,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: FColors.textSecondary,
                                  height: 1.4,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: FSizes.sm),
                      Text(
                        _timeAgo(notification.createdAt),
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: FColors.darkGrey,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Icon(
                  Iconsax.arrow_right_3,
                  size: FSizes.iconSm,
                  color: FColors.darkGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isUnread) {
    return Container(
      width: FSizes.iconCircleSm + FSizes.xs,
      height: FSizes.iconCircleSm + FSizes.xs,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUnread
            ? FColors.primaryColor.withValues(alpha: 0.1)
            : FColors.grey.withValues(alpha: 0.5),
      ),
      child: Icon(
        notification.icon,
        size: FSizes.iconInlineSm,
        color: isUnread ? FColors.primaryColor : FColors.darkGrey,
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now'.tr;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago'.tr;
    if (diff.inHours < 24) return '${diff.inHours}h ago'.tr;
    if (diff.inDays < 7) return '${diff.inDays}d ago'.tr;
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago'.tr;
    return '${date.day}/${date.month}/${date.year}';
  }
}
