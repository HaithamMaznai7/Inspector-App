import 'package:fahis_inspector/features/authentication/views/profile_view.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FUserAvatar extends StatelessWidget {
  const FUserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => const ProfileView()), // Get.toNamed(page),
      child: Center(
        child: CircleAvatar(
          radius: FSizes.md,
          backgroundColor: FColors.grey,
          child: ClipOval(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: FColors.grey,
              child: FirebaseAuth.instance.currentUser?.photoURL != null
              ? CachedNetworkImage(
                  imageUrl: FirebaseAuth.instance.currentUser!.photoURL!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox.shrink(),
                  errorWidget: (_, __, ___) => const Icon(Icons.person, size: 30.0),
                )
              : Icon(
                Icons.person,
                size: 30.0,
                color: FColors.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
