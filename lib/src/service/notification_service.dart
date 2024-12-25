import 'package:event_management/config.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<void> setupFirebaseMessaging() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  final token = await FirebaseMessaging.instance.getToken();
  LoggerService.logger.i('Token: $token');
  await messaging.requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    LoggerService.logger
        .i('Received a message: ${message.notification?.title}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    LoggerService.logger.i('User opened the app from a notification');
  });
}

Future<void> subscribeToTopic(String topic) async {
  String? token = await FirebaseMessaging.instance.getToken();
  LoggerService.logger.i("FCM Token: $token");

  await FirebaseMessaging.instance.subscribeToTopic(topic);
  LoggerService.logger.i("Subscribed to topic: $topic");
}

Future<void> unsubscribeFromTopic(String topic) async {
  await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  LoggerService.logger.i("Unsubscribed from topic: $topic");
}

Future<void> sendNotification(String title, String body, String topic) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    String? idToken = await user.getIdToken();
    final response = await http.post(
      Uri.parse(
          '${Config.baseUrl}/event-service/notification?topic=$topic&title=$title&body=$body'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      LoggerService.logger.i('Send successfully');
    } else {
      LoggerService.logger.e('Failed to send notification');
    }
  } catch (e) {
    LoggerService.logger.w('Error: $e');
  }
}
