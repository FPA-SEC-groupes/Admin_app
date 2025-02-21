import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/models/notifcation.dart' as notif;
import 'package:hello_way/utils/secure_storage.dart';
import '../interceptors/dio_interceptor.dart';
import '../utils/const.dart';

class NotificationViewModel {
  final DioInterceptor dioInterceptor;

  NotificationViewModel(BuildContext context)
      : dioInterceptor = DioInterceptor(context);

  final SecureStorage secureStorage = SecureStorage();

  /// Fetch all notifications
  Future<List<notif.Notification>> fetchNotificationsForUser() async {
    String? userId = await secureStorage.readData(authentifiedUserId);
    final String url = '$baseUrl/api/notifications/providers/$userId/notifications';

    try {
      final response = await dioInterceptor.dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> parsedJson = response.data;
        final List<notif.Notification> notifications =
        parsedJson.map((json) => notif.Notification.fromJson(json)).toList();
        return notifications;
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (error) {
      print('Exception: $error');
      throw Exception('Failed to load notifications: $error');
    }
  }

  /// Mark all notifications as seen
  Future<void> markAllNotificationsAsSeen() async {
    String? userId = await secureStorage.readData(authentifiedUserId);
    final String url = '$baseUrl/api/notifications/providers/$userId/mark-seen';

    try {
      final response = await dioInterceptor.dio.put(url);
      if (response.statusCode == 200) {
        print('All notifications marked as seen');
      } else {
        print('Failed to mark notifications as seen');
      }
    } catch (error) {
      print('Error marking notifications as seen: $error');
    }
  }


  Future<void> updateNotificationAPI(
      int notificationId, String title, message, bool seen,
      ) async {
    try {
      final String url = '$baseUrl/api/notifications/$notificationId';
      final response = await dioInterceptor.dio.put(
        url,
        queryParameters: {
          'title': title,
          'message': message,
          'seen': seen.toString(),
        },
      );

      if (response.statusCode == 200) {
        // The update was successful
        print('Notification updated successfully');
        // You can handle the updated notification data here if needed
      } else {
        // Handle the error when the update was not successful
        print('Failed to update notification');
      }
    } catch (error) {
      // Handle any Dio errors
      print('Error: $error');
    }
  }

  Future<void> deleteNotification(int id) async {

    try {
      Response response = await dioInterceptor.dio.delete(
        '$baseUrl/api/notifications/$id',

      );

      if (response.statusCode == 200) {
        print('Notification deleted successfully');
      } else {
        print('Failed to delete notification');
        // Handle other response codes or errors
      }
    } catch (error) {
      print('An error occurred: $error');
      // Handle DioError or other exceptions
    }
  }
}
