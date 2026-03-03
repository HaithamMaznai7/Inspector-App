import 'dart:io';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/models/notification.dart';
import 'package:fahis_inspector/resources/notification_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../main.dart';

class NotificationsService extends GetxController {
  NotificationsService();

  RxnString fcmToken = RxnString(null);

  NotificationSettings? _settings;

  AuthorizationStatus get permission =>
      _settings?.authorizationStatus ?? AuthorizationStatus.denied;

  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  late NotificationRepository repository;

  RxList<Notification> notifications = RxList([]);
  RxBool isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();

    try {
      // request permission
      await requestPermission();

      await featchFCMToken();

      // Foreground messages
      FirebaseMessaging.onMessage.listen(_foregroundNotification);

      // When the user taps a notification and opens the app
      FirebaseMessaging.onMessageOpenedApp.listen(_openedNotification);

      final box = await Hive.openBox('Notifications');

      repository = NotificationRepository(box: box);

      if (AuthBinding().isRegistered) {
        AuthBinding().instance.tokenChange.listen((token) async {
          // Only fetch when we have a valid token (skip on logout)
          if (token == null) return;
          await featchFCMToken();
          loadNotifications();
        });
      }

      repository.stream.listen((data) {
        dd('[Notifications] stream event: ${data.length} items');
        notifications.assignAll(data);
        update();
      });

      // Load notifications on init
      loadNotifications();

      // When the app is closed
      // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      dd(e.toString());
    }
  }

  void _foregroundNotification(RemoteMessage message) {
    AppLogger.trace('NotificationsService', 'foreground FCM received: "${message.notification?.title}"', 'messageId: ${message.messageId}');
    String? image;

    if (Platform.isAndroid) {
      image = message.notification?.android?.imageUrl;
    } else if (Platform.isIOS) {
      image = message.notification?.apple?.imageUrl;
    } else if (kIsWeb) {
      image = message.notification?.web?.image;
    }

    AppLogger.trace('NotificationsService', 'dispatching foreground notification to FLoader.notification');
    FLoader.notification(
      title: message.notification?.title,
      message: message.notification?.body,
      duration: 5,
      image: image,
    );
  }

  void _openedNotification(RemoteMessage message) {
    AppLogger.trace('NotificationsService', 'notification tapped from system tray: "${message.notification?.title}"', 'messageId: ${message.messageId}');
    String? image;

    if (Platform.isAndroid) {
      image = message.notification?.android?.imageUrl;
    } else if (Platform.isIOS) {
      image = message.notification?.apple?.imageUrl;
    } else if (kIsWeb) {
      image = message.notification?.web?.image;
    }

    AppLogger.trace('NotificationsService', 'dispatching tapped notification to FLoader.notification');
    FLoader.notification(
      title: message.notification?.title,
      message: message.notification?.body,
      duration: 5,
      image: image,
    );
  }

  Future<void> requestPermission() async {
    // iOS permission
    //  && Platform.isIOS
    dd('Request Permission for Notifications');

    _settings = await messaging.requestPermission();
  }

  Future<void> saveFCMToken() async {
    if (fcmToken.value != null &&
        AuthBinding().isRegistered &&
        AuthBinding().instance.token != null) {
      try {
        Network net = Network(
          endpoint: EndPoints.fcmToken,
          requestMethod: RequestMethod.post,
        );

        net.setBody = {'fcm': fcmToken.value};

        final response = await net.response(null);

        dd(response.data['message'] ?? 'FCM Backend: No Message');
      } on FNetworkException catch (e) {
        dd(e.statusCode);
      } catch (_) {
        dd('Error saving FCM Token');
      }
    }
  }

  Future<void> featchFCMToken() async {
    // Get device token for sending notifications

    if (permission != AuthorizationStatus.authorized ||
        permission != AuthorizationStatus.provisional) {
      await requestPermission();
    }

    try {
      dd("Get FCM Token");
      if (kIsWeb) {
        fcmToken.value = await FirebaseMessaging.instance.getToken(
          vapidKey:
              "BAXs8CnPhr171dM9QpE9_HdfhFIS-didzHWVcxsxU8JcfMO-2cHHmXaP-DQNTayuWP8hWwUFcLPfIS4dEg9DN78",
        );
      } else {
        fcmToken.value = await messaging.getToken();
      }
    } catch (e) {
      dd("Error getting FCM Token: $e");
    }

    if (AuthBinding().isRegistered && AuthBinding().instance.isAuth) {
      await saveFCMToken();
    }
  }

  void loadNotifications({bool isRefresh = false}) async {
    // Guard: skip API call if not authenticated (e.g. during logout)
    if (!AuthBinding().isRegistered || !AuthBinding().instance.isAuth) {
      AppLogger.trace('NotificationsService', 'loadNotifications skipped: not authenticated');
      return;
    }

    AppLogger.trace('NotificationsService', 'loadNotifications called (isRefresh: $isRefresh)');
    dd('[Notifications] loadNotifications called (isRefresh: $isRefresh)');
    if (isRefresh) {
      notifications.value = [];
    } else {
      final cached = repository.fetchFromCache();
      AppLogger.trace('NotificationsService', 'cache hit: ${cached.length} notifications loaded');
      dd('[Notifications] cached count: ${cached.length}');
      notifications.assignAll(cached);
    }

    isLoading.value = notifications.isEmpty;
    update();

    AppLogger.trace('NotificationsService', 'fetching notifications from API...');
    final apiData = await repository.fetchFromApi();
    AppLogger.trace('NotificationsService', 'API fetch complete: ${apiData.length} notifications');
    dd('[Notifications] API returned count: ${apiData.length}');
    notifications.assignAll(apiData);

    isLoading.value = false;
    update();
  }

  Future<void> onRefresh() async {
    loadNotifications(isRefresh: true);
  }

  void onOpen(String id) {
    AppLogger.trace('NotificationsService', 'notification opened in-app', 'id: $id');
    read(id);
    notifications
        .where((notification) => notification.id == id)
        .first
        .onOpen();
  }

  void read(String id) async {
    try {
      notifications
          .where((notification) => notification.id == id)
          .first
          .read();
      await repository.update(id);
    } catch (e) {
      rethrow;
    } finally {
      update();
    }
  }

  void unread(String id) async {
    try {
      notifications
          .where((notification) => notification.id == id)
          .first
          .unread();
      await repository.update(id, read: false);
    } catch (e) {
      dd(e.toString());
    } finally {
      update();
    }
  }
}
