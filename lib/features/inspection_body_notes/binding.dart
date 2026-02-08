part of '../../routes.dart';

class InspectionBodyBinding extends BindingsService<InspectionBodyController> {
  
  @override
  final String? tag = BindingTags.inspectionBody;

  @override
  void dependencies() async {
    if (isRegistered) {
      Get.delete<InspectionBodyController>(tag: tag);
    }

    Get.put<InspectionBodyController>(
      InspectionBodyController(),
      tag: tag,
    );
  }
}
