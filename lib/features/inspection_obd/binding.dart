part of '../../routes.dart';

class InspectionObdBinding extends BindingsService<InspectionObdController> {
  InspectionObdBinding() : super(tag: BindingTags.inspectionOBD);

  @override
  void dependencies() async {

    if (isRegistered) {
      Get.delete<InspectionObdController>(tag: tag);
    }

    Get.put<InspectionObdController>(
      InspectionObdController(),
      tag: tag,
    );
  }
}
