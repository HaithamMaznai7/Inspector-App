part of '../../routes.dart';

class InspectionPhotosBinding extends BindingsService<InspectionPhotosController> {
  InspectionPhotosBinding() : super(tag: BindingTags.inspectionPhotos);

  @override
  void dependencies() async {
    if (isRegistered) {
      Get.delete<InspectionPhotosController>(tag: tag);
    }

    Get.put<InspectionPhotosController>(
      InspectionPhotosController(),
      tag: tag,
    );

  }
}
