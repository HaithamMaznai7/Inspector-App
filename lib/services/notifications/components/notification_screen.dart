import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Notifications Center',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.copyWith(color: FColors.primaryColor),
        ),
        centerTitle: true,
        leading: BackPageButton(),
      ),
      body: GetBuilder(
        init: NotificationsBinding().instance,
        builder: (c) {
          final notifications = c.notifications.value;
          return RefreshIndicator(
            onRefresh: c.onRefresh,
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(color: FColors.grey, thickness: 1);
              },
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return ListTile(
                  onLongPress: () => notification.readAt == null ?  c.read(notification.id) : c.unread(notification.id),
                  onTap: () => c.onOpen(notification.id),
                  tileColor: notification.readAt == null
                      ? FColors.grey
                      : FColors.softGrey,
                  title: Text(notification.title),
                  isThreeLine: false,
                  subtitle: Text(notification.description),
                  trailing: notification.readAt == null
                      ? Container(
                          padding: EdgeInsets.all(FSizes.sm / 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              FSizes.borderRadiusSm,
                            ),
                            color: FColors.info,
                          ),
                          child: Text(
                            'new',
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(color: FColors.white),
                          ),
                        )
                      : null, // notification.readAt == null ? Icons.open_in_new :
                );
              },
            ),
          );
        },
      ),
    );
  }
}
