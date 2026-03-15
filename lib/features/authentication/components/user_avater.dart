import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/features/authentication/views/profile_view.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FUserAvatar extends StatelessWidget {
  const FUserAvatar({super.key});

  /// Returns true only when the URL is a real uploaded photo,
  /// not the ui-avatars.com generated placeholder.
  bool _hasRealAvatar(String? url) =>
      url != null &&
      url.isNotEmpty &&
      !url.contains('ui-avatars.com');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => const ProfileView()),
      child: Obx(() {
        final avatarUrl = auth().profileRx.value?.avatar;
        final hasAvatar = _hasRealAvatar(avatarUrl);

        return CircleAvatar(
          radius: FSizes.md,
          backgroundColor: FColors.grey.withValues(alpha: 0.3),
          child: ClipOval(
            child: SizedBox(
              width: FSizes.md * 2,
              height: FSizes.md * 2,
              child: hasAvatar
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _defaultIcon(),
                      errorWidget: (_, __, ___) => _defaultIcon(),
                    )
                  : _defaultIcon(),
            ),
          ),
        );
      }),
    );
  }

  Widget _defaultIcon() => Center(
        child: Icon(
          Icons.person,
          size: 22,
          color: FColors.primaryColor,
        ),
      );
}
