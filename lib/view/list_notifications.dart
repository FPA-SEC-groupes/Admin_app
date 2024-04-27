import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hello_way/utils/routes.dart';

import 'package:hello_way/view_model/notifications_view_model.dart';
import 'package:hello_way/models/notifcation.dart' as notif;
import 'package:provider/provider.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../utils/secure_storage.dart';
import '../widgets/item notfication.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ListNotifications extends StatefulWidget {
  ListNotifications({Key? key}) : super(key: key);

  @override
  _ListNotificationsState createState() => _ListNotificationsState();
}

class _ListNotificationsState extends State<ListNotifications> {
  late NotificationViewModel _notificationViewModel;
  final SecureStorage secureStorage = SecureStorage();
  bool authentifiedUser = false;

  @override
  void initState() {
    super.initState();
    _notificationViewModel = NotificationViewModel(context);
    _getNotifications();
  }

  Future<List<notif.Notification>> _getNotifications() async {

    return _notificationViewModel.fetchNotificationsForUser();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.notifications), automaticallyImplyLeading: false),
      body: networkStatus == NetworkStatus.Online
          ? FutureBuilder<List<notif.Notification>>(
        future: _getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While fetching data, show a loading indicator
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty)  {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_off_rounded,
                      size: 150,
                      color: gray,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.noNotifications,
                      style: const TextStyle(fontSize: 22, color: gray),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // If there's an error, show an error message
            return Center(child: Text(AppLocalizations.of(context)!.errorRetrievingData));
          } else {
            // If there's no data or error, show an empty widget

            final notifications = snapshot.data!.reversed.toList();
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => Container(color: lightGray, height: 10),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ItemNotification(notification: notification,
                  onDelete:() async {
                  await _notificationViewModel.deleteNotification(notification.id)   .then((_) async {
                    setState(() {
                  _getNotifications();
                    });
                  }).catchError((error) {});
                });
              },
            );
          }
        },
      ):Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.network_check,
                size: 150,
                color: gray,
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.noInternet,
                style: const TextStyle(fontSize: 22, color: gray),
                textAlign: TextAlign.center,
              ),
              Text(
                AppLocalizations.of(context)!.checkYourInternet,
                style: const TextStyle(fontSize: 22, color: gray),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10,),
              MaterialButton(
                color: orange,
                height: 40,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed:(){
                  setState(() {

                  });
                },


                child: Text(
                  AppLocalizations.of(context)!.retry,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),

              )
            ],
          ),
        ),
      ),
    );
  }
}
