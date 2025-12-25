import 'package:fahis_inspector/common/widget/logo.dart';
import 'package:fahis_inspector/features/notifications/controller/controller.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>(
      tag: 'NotificationService',
    );

    return Obx(() {
      final showen = controller.notifications.isNotEmpty;
      // ignore: invalid_use_of_protected_member
      final notifications = controller.notifications.value;
      return Scaffold(
        appBar: AppBar(
          title: Logo(height: 30),
          centerTitle: true,
          actions: [
            if (showen)
              IconButton(
                onPressed: () => print('read all'),
                icon: Icon(
                  Icons.mark_chat_read_outlined,
                  color: FColors.primaryColor,
                ),
              ),
            if (showen)
              IconButton(
                onPressed: () => print('delete all'),
                icon: Icon(Iconsax.trash, color: FColors.error),
              ),
          ],
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              FLocalization.isArabic
                  ? Iconsax.arrow_right_3
                  : Iconsax.arrow_left_2,
              color: FColors.primaryColor,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: FSizes.sm),
          child: RefreshIndicator(
            color: FColors.primaryColor,
            onRefresh: controller.refresh,
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications.elementAt(index);
                return Slidable(
                  key: ValueKey(index),
                  startActionPane: ActionPane(
                    // A motion is a widget used to control how the pane animates.
                    motion: const ScrollMotion(),
                    // A pane can dismiss the Slidable.
                    dismissible: DismissiblePane(onDismissed: () {}),

                    // All actions are defined in the children parameter.
                    children: [
                      // A SlidableAction can have an icon and/or a label.
                      SlidableAction(
                        onPressed: (context) => print('delete'),
                        backgroundColor: FColors.error,
                        foregroundColor: FColors.white,
                        icon: Iconsax.trash,
                        label: 'Delete',
                      ),
                      SlidableAction(
                        onPressed: (context) => print('read'),
                        backgroundColor: FColors.primaryColor,
                        foregroundColor: Colors.white,
                        icon: Icons.mark_chat_read,
                        label: 'read',
                      ),
                    ],
                  ),
                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 2,
                        onPressed: (context) => print('delete'),
                        backgroundColor: FColors.error,
                        foregroundColor: FColors.white,
                        icon: Iconsax.trash,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: FSizes.md),
                    title: Text(notification.title),
                    subtitle: Text(notification.description),
                    trailing: Icon(Icons.mark_chat_read),
                    tileColor: FColors.grey,
                    onTap: () => print(notification.type),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}
