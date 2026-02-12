part of '../../routes.dart';

class NotificationsBinding extends BindingsService<NotificationsService> {
  
  @override
  final String? tag = BindingTags.notificationsService;

  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationsService>(tag: tag)) {
      Get.put<NotificationsService>(NotificationsService(), tag: tag, permanent: true);
    }
  }
}
