part of '../../routes.dart';

class HomeBinding extends BindingsService<HomeController> {
  HomeBinding() : super(tag: BindingTags.home);

  @override
  void dependencies() async {

    if (Get.isRegistered<HomeController>(tag: tag)) {
      Get.delete<HomeController>(tag: tag);
    }

    Get.put<HomeController>(HomeController(), tag: tag);
  }
}
