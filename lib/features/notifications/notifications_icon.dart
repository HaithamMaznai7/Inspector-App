import 'package:fahis_inspector/features/notifications/controller/controller.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NotificationIcon extends StatelessWidget {
  final NotificationsController controller;
  const NotificationIcon({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // final count = controller.notifications.length;
      return Badge(
        label: Text(controller.notifications.length.toString()),
        backgroundColor: FColors.error,
        largeSize: 18,
        isLabelVisible: controller.notifications.length > 0,
        offset: Offset(-5, 5),
        alignment: Alignment.topRight,
        child: IconButton(
          onPressed: () => Get.toNamed(RoutingUrl.notifications),
          icon: Icon(Iconsax.notification, color: FColors.primaryColor),
        ),
      );
    });
  }
}
