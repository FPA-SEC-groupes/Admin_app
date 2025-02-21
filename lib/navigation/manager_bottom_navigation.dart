import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hello_way/view/list_notifications.dart';
import 'package:hello_way/view_model/notifications_view_model.dart';
import 'package:hello_way/models/notifcation.dart' as notif;
import '../res/app_colors.dart';
import '../utils/secure_storage.dart';
import '../view/manager/list.dart';
import '../view/manager/menu.dart';
import '../view/manager/list_waiters.dart';
import '../view/manager/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ManagerBottomNavigation extends StatefulWidget {
  final int? index;
  const ManagerBottomNavigation({this.index});

  @override
  State<ManagerBottomNavigation> createState() => _ManagerBottomNavigationState();
}

class _ManagerBottomNavigationState extends State<ManagerBottomNavigation> {
  int _currentIndex = 0;
  int unseenNotifications = 0;
  StreamSubscription<void>? _streamSubscription;
  late NotificationViewModel _notificationViewModel;
  final SecureStorage secureStorage = SecureStorage();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final List<Widget> _interfaces = [
    Menu(),
    ListReservations(),
    ListWaiters(),
    ListNotifications(),
    Settings()
  ];

  /// Fetch unseen notifications count
  Future<void> fetchUnseenNotifications() async {
    try {
      List<notif.Notification> notifications = await _notificationViewModel.fetchNotificationsForUser();
      int newUnseenCount = notifications.where((n) => !n.seen).length;

      if (mounted) {
        setState(() {
          unseenNotifications = newUnseenCount;
        });
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  /// Listen for Firebase Push Notifications
  void setupFirebaseNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("New Notification: ${message.notification?.title}");

      // Refresh unseen notifications count
      fetchUnseenNotifications();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("Notification Clicked: ${message.notification?.title}");

      // When clicked, mark notifications as read
      await _notificationViewModel.markAllNotificationsAsSeen();
      setState(() {
        unseenNotifications = 0;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index ?? 0;
    _notificationViewModel = NotificationViewModel(context);

    // Initial fetch of unseen notifications
    fetchUnseenNotifications();

    // Listen for Firebase Push Notifications
    setupFirebaseNotifications();

    // Periodic check every 10 seconds
    _streamSubscription = Stream.periodic(const Duration(seconds: 10)).listen((_) async {
      await fetchUnseenNotifications();
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDialogTitle),
            content: Text(AppLocalizations.of(context)!.confirmDialogMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: Text(AppLocalizations.of(context)!.confirmDialogExit),
              ),
            ],
          ),
        );
        return false;
      },
      child: Scaffold(
        body: _interfaces[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: orange,
          unselectedItemColor: gray,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: ""),
            const BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: ""),
            const BottomNavigationBarItem(icon: Icon(Icons.group_rounded), label: ""),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_rounded),
                  if (unseenNotifications > 0)
                    Positioned(
                      right: -1,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Text(
                          unseenNotifications.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: "",
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: "")
          ],
          currentIndex: _currentIndex,
          onTap: (value) async {
            setState(() {
              _currentIndex = value;
            });

            if (_currentIndex == 3) {
              await _notificationViewModel.markAllNotificationsAsSeen();
              setState(() {
                unseenNotifications = 0;
              });
            }
          },
        ),
      ),
    );
  }
}
