import 'package:fahis_inspector/features/authentication/views/profile_view.dart';
import 'package:fahis_inspector/features/authentication/views/team_selector_sheet.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
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
      icon: Icon(Iconsax.arrow_down_1, size: FSizes.defaultSpace, color: FColors.white),
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
                  Icon(Iconsax.user, size: FSizes.fontSizeLg, color: FColors.primaryColor),
                  const SizedBox(width: FSizes.sm),
                  Flexible(
                    child: Text(
                      FTexts.profileTitle.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              onTap: () => Get.to(() => const ProfileView()),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Iconsax.people, size: FSizes.fontSizeLg, color: FColors.primaryColor),
                  const SizedBox(width: FSizes.sm),
                  Flexible(
                    child: Text(
                      'Switch Team'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              onTap: () => TeamSelectorSheet.show(),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Iconsax.logout, size: FSizes.fontSizeLg, color: Colors.red),
                  const SizedBox(width: FSizes.sm),
                  Flexible(
                    child: Text(
                      FTexts.logoutBtn.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              onTap: () async {
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: Text(FTexts.logoutConfirmTitle.tr),
                    content: Text(FTexts.logoutConfirmMessage.tr),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(FTexts.cancelBtn.tr),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(FTexts.logoutBtn.tr),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) await auth().logOut();
              },
            ),
          ],
        );
      },
    );
  }
}
