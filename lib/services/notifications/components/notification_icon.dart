import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/notifications/components/notification_screen.dart';
import 'package:fahis_inspector/services/notifications/notifications_service.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsService>(
      init: NotificationsBinding().instance,
      builder: (controller) {
        return Badge.count(
          count: controller.notifications.length,
          alignment: Alignment.topRight,
          isLabelVisible: controller.notifications.isNotEmpty,
          offset: Offset(-8, 8),
          maxCount: 99,
          child: IconButton(
            onPressed: () => Get.to(() => const NotificationScreen()),
            icon: Icon(Iconsax.notification, color: FColors.primaryColor),
          ),
        );
      },
    );
  }
}
