part of '../../routes.dart';

class VehicleDetailsBinding extends BindingsService<VehicleDetailsController> {
  VehicleDetailsBinding() : super(tag: BindingTags.vehicleDetails);

  @override
  void dependencies() async {

    if (isRegistered) {
      Get.delete<VehicleDetailsController>(tag: tag);
    }else{
      Get.put<VehicleDetailsController>(VehicleDetailsController(), tag: tag);
    }
  }
}
