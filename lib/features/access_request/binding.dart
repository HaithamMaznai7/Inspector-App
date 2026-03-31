part of '../../routes.dart';

class AccessRequestBinding extends BindingsService<AccessRequestController> {
  AccessRequestBinding() : super(tag: BindingTags.accessRequest);

  @override
  void dependencies() async {
    if (Get.isRegistered(tag: tag)) {
      final AccessRequestController controller =
          Get.find<AccessRequestController>(tag: tag);
      controller.onClose();
    }

    Get.put<AccessRequestController>(AccessRequestController(), tag: tag);
  }
}
