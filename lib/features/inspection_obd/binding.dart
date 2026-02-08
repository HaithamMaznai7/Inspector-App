part of '../../routes.dart';

class InspectionObdBinding extends BindingsService<InspectionObdController> {
  
  @override
  final String? tag = BindingTags.inspectionOBD;

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
