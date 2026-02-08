import 'package:get/get.dart';

abstract class BindingsService<B> implements Bindings {
  final String? tag;

  const BindingsService({this.tag});


  @override
  void dependencies();
  
  bool get isRegistered => Get.isRegistered<B>(tag: tag);

  B get instance {
    if (! isRegistered) {
      dependencies();
    }

    return Get.find<B>(tag: tag);
  }
}
