import 'package:fahis_inspector/app/services/app_service.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  /// Update Current Index when Page Scroll
  void updatePageIndicator(index) => currentPageIndex.value = index;

  /// Update Current Index when Page Scroll
  void dotNavigatorClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  /// Update Current Index when Page Scroll
  void nextPage() {
    if (currentPageIndex.value == 2) {
      AppService.getBox?.put('IS_BOARDER', true);

      Get.offAllNamed(RoutingUrl.login);
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  /// Update Current Index when Page Scroll
  void skipPage() {

    AppService.getBox?.put('IS_BOARDER', true);

    Get.offAllNamed(RoutingUrl.login);
  }
}
