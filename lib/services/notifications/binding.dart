part of '../../routes.dart';

class NotificationsBinding extends BindingsService<NotificationsService> {
  
  @override
  final String? tag = BindingTags.notificationsService;

  @override
  void dependencies() {
    if (!Get.isRegistered(tag: tag)) {
      Get.lazyPut<NotificationsService>(() => NotificationsService(), tag: tag);
    }
  }
}
