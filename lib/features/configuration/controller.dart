import 'package:fahis_inspector/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnBoardingController extends GetxController {

  /// Variables
  static const int totalPages = 3;
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  bool get isLastPage => currentPageIndex.value == totalPages - 1;

  void updatePageIndicator(int index) => currentPageIndex.value = index;

  void dotNavigatorClick(int index) {
    currentPageIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void nextPage() async {
    if (isLastPage) {
      await _markOnboardingSeen();
      Get.offAllNamed(RoutingUrl.join);
    } else {
      pageController.animateToPage(
        currentPageIndex.value + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipPage() async {
    await _markOnboardingSeen();
    Get.offAllNamed(RoutingUrl.join);
  }

  Future<void> _markOnboardingSeen() async {
    final settingsBox = await Hive.openBox('AppSettings');
    await settingsBox.put('hasSeenOnboarding', true);
  }
}
