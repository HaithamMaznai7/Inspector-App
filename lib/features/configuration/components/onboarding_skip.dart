import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: FDeviceUtils.getAppBarHeight(),
      right: FSizes.defaultSpace,
      child: TextButton(
        onPressed: () =>
            OnBoardingBinding().instance.skipPage(),
        child: Container(
          decoration: BoxDecoration(
            color: FHelper.isDarkMode(context)
                ? FColors.darkGrey.withOpacity(.6)
                : FColors.grey,
            borderRadius: BorderRadiusDirectional.circular(FSizes.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.lg,
            vertical: FSizes.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.arrow_right_1,
                color: FHelper.isDarkMode(context)
                    ? FColors.white
                    : FColors.black,
                size: 15,
              ),
              Text(
                FTexts.skip.tr,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
