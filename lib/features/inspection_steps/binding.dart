part of '../../routes.dart';

class InspectionStepsBinding
    extends BindingsService<InspectionStepsController> {
  @override
  final String? tag = BindingTags.inspectionDetails;

  @override
  void dependencies() async {
    final inspection = Get.arguments as Inspection?;
    if (inspection == null) {
      Get.offAllNamed(RoutingUrl.home);
      return;
    }

    if (isRegistered) {
      Get.delete<InspectionStepsController>(tag: tag);
    }

    Get.put<InspectionStepsController>(InspectionStepsController(), tag: tag);
  }
}
