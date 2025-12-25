import 'package:fahis_inspector/features/notifications/model/notification.dart';
import 'package:fahis_inspector/features/notifications/repository/repository.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationsController extends GetxController {
  late final NotificationRepository repository;

  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() async {
    super.onInit();

    final userId = Auth.user?.id;
    if (userId == null) {
      Auth.logout();
      return;
    }

    final box = await Hive.openBox<List<Map<String, dynamic>>>(
      NotificationRepository.cacheKey,
    );

    repository = NotificationRepository(box);

    repository.get().listen((data) {
      notifications.assignAll(data);
      update();
    }, onError: (e) {});
  }

  Future<void> refresh() async {
    // Fetch from backend or local storage
    // await repository.fetchFromApi(); // hypothetical
  }

  void markAllAsRead() {
    for (var n in notifications) {
      n.readAt = DateTime.now(); // assuming you have `isRead` field
    }
    notifications.refresh();
    // optionally, send to backend
  }

  void deleteAll() {
    notifications.clear();
  }

  void deleteNotification(int index) {
    notifications.removeAt(index);
  }

  void markAsRead(int index) {
    notifications[index].readAt = DateTime.now();
    notifications.refresh();
  }
}
