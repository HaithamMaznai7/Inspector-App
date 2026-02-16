import 'package:fahis_inspector/features/authentication/views/profile_view.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class UserWidget extends StatelessWidget {
  UserWidget({super.key});

  final GlobalKey _iconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _iconKey,
      icon: Icon(Iconsax.arrow_down_1, size: 25, color: FColors.white),
      onPressed: () async {
        final RenderBox button =
            _iconKey.currentContext!.findRenderObject() as RenderBox;

        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;

        final Offset position =
            button.localToGlobal(Offset.zero, ancestor: overlay);

        await showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            position.dx,
            position.dy + button.size.height,
            0,
            0,
          ),
          items: [
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Iconsax.user, size: 18, color: FColors.primaryColor),
                  const SizedBox(width: 8),
                  Text(FTexts.profileTitle.tr),
                ],
              ),
              onTap: () => Get.to(() => const ProfileView()),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Iconsax.logout, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    FTexts.logoutBtn.tr,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
              onTap: () async => await auth().logOut(),
            ),
          ],
        );
      },
    );
  }
}
