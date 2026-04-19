part of '../../routes.dart';

class InspectionDetailsBinding extends BindingsService<InspectionDetailsController> {
  InspectionDetailsBinding() : super(tag: BindingTags.inspectionDetails);

  @override
  void dependencies() async {
    // Short-circuit: GetBuilder(init: Binding().instance) re-invokes this on
    // widget rebuilds where the controller is already alive. Tearing it down
    // destroys the screen state and triggers a navigation loop on offline.
    if (isRegistered) return;

    if (Get.parameters['slug'] == null) {
      Get.offAllNamed(RoutingUrl.home);
      return;
    }

    Get.put<InspectionDetailsController>(
      InspectionDetailsController(),
      tag: tag,
    );
  }
}
