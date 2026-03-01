part of '../../routes.dart';

class InspectionDetailsBinding extends BindingsService<InspectionDetailsController> {
  InspectionDetailsBinding() : super(tag: BindingTags.inspectionDetails);

  @override
  void dependencies() async {
    if (Get.parameters['slug'] == null) {
      Get.offAllNamed(RoutingUrl.home);
      return;
    }

    if (isRegistered) {
      Get.delete<InspectionDetailsController>(tag: tag);
    }

    Get.put<InspectionDetailsController>(
      InspectionDetailsController(),
      tag: tag,
    );
  }
}
