import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:hello_way/models/notifcation.dart' as notif;
import 'package:hello_way/view_model/notifications_view_model.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';

class PushNotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late NotificationViewModel _notificationViewModel;
  final SecureStorage secureStorage = SecureStorage();
  List<notif.Notification> notifications = [];
  PushNotificationService({
    required this.flutterLocalNotificationsPlugin,
    required BuildContext context,
  }) {
    _notificationViewModel =
        NotificationViewModel(context); // Initialize NotificationViewModel
  }

  Future<void> init() async {
    const interval = Duration(seconds: 30);
    String? role = await secureStorage.readData(roleKey);
    if( role!=roleAdmin){
    Stream.periodic(interval).listen((_) async {
      String? userId = await secureStorage.readData(authentifiedUserId);

      print(userId);
      if (userId != null) {
        _notificationViewModel
            .fetchNewNotificationsForUser(userId)
            .then((fetchedNotifications) async {
          int notificationCount;
          String? nbNotifications =
              await secureStorage.readData(nbNewNotifications);
          if( fetchedNotifications.isNotEmpty){
          if (nbNotifications != null ) {
            print("nbNotifications" + nbNotifications.toString());
            notificationCount =
                int.parse(nbNotifications) + fetchedNotifications.length;
            print("fetchedNotifications"+fetchedNotifications.length.toString());
          } else {
            notificationCount = fetchedNotifications.length;
          }
          await secureStorage.writeData(
              nbNewNotifications, notificationCount.toString());}
          for (var notification in fetchedNotifications) {
            _showNotification(
                notification.id, notification.title, notification.message);
          }
        }).catchError((error) {
          // Gérer les erreurs, par exemple, afficher un snackbar ou un message toast
          print('Erreur lors de la récupération des notifications : $error');
        });
      } else {
        // If userId is null, cancel the timer to stop periodic fetching.

        print('User is not authenticated. Stopping periodic fetching.');
      }
    });}
  }

  Future<void> _showNotification(
      int notificationId, String title, String body) async {
    // Check if the notification ID is already in the list of shown notifications

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Replace with your own channel ID
      'Channel Name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
    );

    // Add the notification ID to the list of shown notifications
    _notificationViewModel.updateNotificationAPI(
        notificationId, title, body, true);
  }
}

extension PushNotificationServiceExtension on BuildContext {
  PushNotificationService get pushNotificationService =>
      read<PushNotificationService>();
}
