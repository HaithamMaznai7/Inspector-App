import 'package:fahis_inspector/features/configuration/controller.dart';
import 'package:fahis_inspector/features/configuration/components/onboarding_page.dart';
import 'package:fahis_inspector/features/configuration/components/onboarding_skip.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/image_strings.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                image: FImages.onBoardingImage1,
                title: OnBoardingTexts.onBoardingTitle1,
                subTitle: OnBoardingTexts.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: FImages.onBoardingImage2,
                title: OnBoardingTexts.onBoardingTitle2,
                subTitle: OnBoardingTexts.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: FImages.onBoardingImage3,
                title: OnBoardingTexts.onBoardingTitle3,
                subTitle: OnBoardingTexts.onBoardingSubTitle3,
              ),
            ],
          ),

          const OnBoardingSkip(),

          const OnBoarderDotNavigation(),

          const OnBoardingNextBtn(),
        ],
      ),
    );
  }
}

class OnBoardingNextBtn extends StatelessWidget {
  const OnBoardingNextBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: FLocalization.isArabic ? FSizes.defaultSpace : null,
      right: FLocalization.isArabic ? null : FSizes.defaultSpace,
      bottom: FDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () =>
            OnBoardingBinding().instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: FColors.primaryColor,
        ),
        child: Icon(
          FLocalization.isArabic ? Iconsax.arrow_left_2 : Iconsax.arrow_right_3,
        ),
      ),
    );
  }
}

class OnBoarderDotNavigation extends StatelessWidget {
  const OnBoarderDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingBinding().instance;

    return Positioned(
      right: FLocalization.isArabic ? FSizes.defaultSpace : null,
      left: FLocalization.isArabic ? null : FSizes.defaultSpace,
      bottom: FDeviceUtils.getBottomNavigationBarHeight() + 25,
      child: SmoothPageIndicator(
        count: 3,
        controller: controller.pageController,
        onDotClicked: controller.dotNavigatorClick,
        effect: const ExpandingDotsEffect(
          activeDotColor: FColors.primaryColor,
          dotHeight: 6,
        ),
      ),
    );
  }
}
