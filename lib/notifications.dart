import 'dart:io';
import 'package:fahis_inspector/app/services/app_service.dart';
import 'package:get/get.dart';

import '/main.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  @pragma('vm:entry-point') // 👈 VERY IMPORTANT
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  void _firebaseMessagingForgroundHandler(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  Future<void> initializeServices() async {
    // WidgetsFlutterBinding.ensureInitialized();

    // await Hive.initFlutter();

    dd('Initializing Firebase...');
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    dd('Initialized Firebase...');

    // iOS permission
    dd('Request Firebase Messaging Permission...');
    if (!kIsWeb && Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();
    }

    dd('Creating Local Notification Channel...');
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 🔔 Setup foreground notifications
    dd('Creating Local Notification Channel...');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    dd('Creating Local Notification Channel...');
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForgroundHandler);

  }

}

