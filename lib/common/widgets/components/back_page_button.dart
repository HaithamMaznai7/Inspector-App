import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class BackPageButton extends StatelessWidget {
  final String? route;
  final Color? color;
  const BackPageButton({super.key, this.route, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (route != null) {
          Get.offAllNamed(route!);
        } else {
          // try{
          Get.back();
          // } catch (_){
          //   Get.offAllNamed(
          //     RoutingUrl.home,
          //   ); // or your app's default page
          // }
        }
      },
      icon: Icon(
        FLocalization.isArabic ? Iconsax.arrow_right_3 : Iconsax.arrow_left_2,
        color: color ?? FColors.primaryColor,
        size: 20,
      ),
    );
  }
}
