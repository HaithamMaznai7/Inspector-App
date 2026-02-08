part of 'main.dart';

// This will handle messages when the app is in background or terminated
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  dd('Background message received: ${message.messageId}');
}