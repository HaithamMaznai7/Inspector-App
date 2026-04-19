part of '../../routes.dart';

class InspectionStepsBinding
    extends BindingsService<InspectionStepsController> {
  InspectionStepsBinding() : super(tag: BindingTags.inspectionDetails);

  @override
  void dependencies() async {
    // Short-circuit: GetBuilder(init: Binding().instance) re-invokes this on
    // widget rebuilds where the controller is already alive. Tearing it down
    // destroys the screen state and triggers a navigation loop on offline.
    if (isRegistered) return;

    final inspection = Get.arguments as Inspection?;
    if (inspection == null) {
      Get.offAllNamed(RoutingUrl.home);
      return;
    }

    Get.put<InspectionStepsController>(InspectionStepsController(), tag: tag);
  }
}
