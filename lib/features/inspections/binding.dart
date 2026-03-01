part of '../../routes.dart';

class InspectionsBinding extends BindingsService<InspectionsController> {
  InspectionsBinding() : super(tag: BindingTags.inspections);

  @override
  void dependencies() async {
    if (isRegistered) {
      Get.find<InspectionsController>(tag: tag);
    } else {
      Get.put<InspectionsController>(InspectionsController(), tag: tag);
    }
  }
}
