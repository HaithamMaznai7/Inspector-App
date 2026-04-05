part of '../../routes.dart';

class PaintGaugeBinding extends BindingsService<PaintGaugeController> {
  PaintGaugeBinding() : super(tag: BindingTags.paintGauge);

  @override
  void dependencies() async {
    if (isRegistered) {
      Get.delete<PaintGaugeController>(tag: tag);
    }

    Get.put<PaintGaugeController>(
      PaintGaugeController(),
      tag: tag,
    );
  }
}
