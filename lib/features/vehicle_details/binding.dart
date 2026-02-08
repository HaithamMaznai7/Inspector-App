part of '../../routes.dart';

class VehicleDetailsBinding extends BindingsService<VehicleDetailsController> {

  @override
  final String? tag = BindingTags.vehicleDetails;

  @override
  void dependencies() async {

    if (isRegistered) {
      Get.delete<VehicleDetailsController>(tag: tag);
    }else{
      Get.put<VehicleDetailsController>(VehicleDetailsController(), tag: tag);
    }
  }
}
