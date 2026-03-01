part of '../../routes.dart';

class StorageBinding extends BindingsService<StorageService> {
  StorageBinding() : super(tag: BindingTags.storageService);

  @override
  void dependencies() {
    if (!Get.isRegistered<StorageService>(tag: tag)) {
      Get.put<StorageService>(StorageService(), tag: tag, permanent: true);
    }
  }
}
