part of '../../routes.dart';

class OnBoardingBinding extends BindingsService<OnBoardingController> {
  
  @override
  final String? tag = BindingTags.onBoarding;

  @override
  void dependencies() async {
    if (Get.isRegistered<OnBoardingController>(tag: tag)) {
      Get.delete<OnBoardingController>(tag: tag);
    }

    Get.put<OnBoardingController>(OnBoardingController(), tag: tag);
  }
}
