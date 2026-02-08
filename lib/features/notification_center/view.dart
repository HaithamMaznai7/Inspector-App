import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Logo(height: 30), leading: BackPageButton()),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: FSizes.sm,
          vertical: FSizes.md,
        ),
        child: ListView.builder(
          itemBuilder: (context, index) {
            return NotificationCard(
              uid: 'Key_$index',
              title: 'title',
              subtitle: 'subtitle',
            );
          },
          // separatorBuilder: (context, index) {
          //   return Divider();
          // },
          itemCount: 10,
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String uid;
  final String title;
  final String subtitle;

  const NotificationCard({
    super.key,
    required this.uid,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: GlobalKey(debugLabel: uid),
      closeOnScroll: true,
      endActionPane: ActionPane(
        dismissible: SlidableAction(
          icon: Iconsax.trash,
          backgroundColor: FColors.error,
          onPressed: (context) => dd('object'),
        ),
        motion: SlidableAction(
          icon: Iconsax.trash,
          backgroundColor: FColors.error,
          onPressed: (context) => dd('object'),
        ),
        extentRatio: .1,
        children: [
          SlidableAction(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            foregroundColor: FColors.info,
            icon: Iconsax.message,
            onPressed: (context) => dd('Delete'),
          ),
          SlidableAction(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            icon: Iconsax.trash,
            onPressed: (context) => dd('Read'),
          ),
        ],
      ),
      child: Card(
        color: FColors.info.withOpacity(.10),
        child: ListTile(
          title: Text(title),
          isThreeLine: false,
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}
