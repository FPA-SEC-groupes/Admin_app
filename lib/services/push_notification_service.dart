import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final BuildContext context;

  PushNotificationService({
    required this.flutterLocalNotificationsPlugin,
    required this.context,
  });

  Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  void _handleMessage(RemoteMessage message) {
    print('Received a message while in the foreground: ${message.messageId}');
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      _showNotification(notification);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message clicked!');
  }

  void _showNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('your_channel_id', 'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, notification.title, notification.body, platformChannelSpecifics);
  }
}
