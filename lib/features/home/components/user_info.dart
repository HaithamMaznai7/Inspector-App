import 'package:fahis_inspector/features/authentication/views/profile_view.dart';
import 'package:fahis_inspector/features/home/controller.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class UserWidget extends StatelessWidget {
  UserWidget({super.key});

  final GlobalKey _iconKey = GlobalKey();

  HomeController get controller => HomeBinding().instance;

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
            position.dy + button.size.height, // ⬇️ below button
            0,
            0,
          ),
          items: [
            PopupMenuItem(
              child: Text('Profile'),
              onTap: () => Get.to(ProfileView()),
            ),
            if (auth().profile != null)
            ...auth().profile!.teams.where((team) => team.isJoined).toList().map((
              team,
            ) {
              return PopupMenuItem(
                enabled: auth().profile!.currentTeam?.id != team.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name ?? 'Team',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      team.role ?? 'User',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                onTap: () => controller.changeTeam(team),
              );
            }),
            PopupMenuItem(
              child: Text('Logout'),
              onTap: () async => await auth().logOut(),
            ),
          ],
        );
      },
    );
  }
}
