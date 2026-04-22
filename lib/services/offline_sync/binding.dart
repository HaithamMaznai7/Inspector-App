part of '../../routes.dart';

class OfflineSyncBinding extends BindingsService<OfflineSyncService> {
  OfflineSyncBinding() : super(tag: BindingTags.offlineSync);

  @override
  void dependencies() {
    if (!Get.isRegistered<OfflineSyncService>(tag: tag)) {
      Get.put<OfflineSyncService>(
        OfflineSyncService(),
        tag: tag,
        permanent: true,
      );
    }
  }
}
