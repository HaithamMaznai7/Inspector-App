part of '../../routes.dart';

class StorageBinding extends BindingsService<StorageService> {
  
  @override
  final String? tag = BindingTags.storageService;

  @override
  void dependencies() {
    if (!Get.isRegistered(tag: tag)) {
      Get.lazyPut<StorageService>(() => StorageService(), tag: tag);
    }
  }
}
