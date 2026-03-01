part of '../../routes.dart';

class InspectionPointsBinding extends BindingsService<InspectionPointsController> {
  InspectionPointsBinding() : super(tag: BindingTags.inspectionPoints);

  @override
  void dependencies() async {
    if (isRegistered) {
      Get.delete<InspectionPointsController>(tag: tag);
    }
    
    Get.put<InspectionPointsController>(
      InspectionPointsController(),
      tag: tag,
    );

  }
}
