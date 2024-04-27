import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_way/view/list_notifications.dart';
import 'package:hello_way/view/waiter/menu.dart';
import 'package:hello_way/view/waiter/settings.dart';

import '../res/app_colors.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';
import '../view/profile.dart';
import '../view/waiter/list_commands.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class WaiterBottomNavigation extends StatefulWidget {
  const WaiterBottomNavigation({Key? key}) : super(key: key);

  @override
  State<WaiterBottomNavigation> createState() =>
      _WaiterBottomNavigationState();
}

class _WaiterBottomNavigationState extends State<WaiterBottomNavigation> {
  final SecureStorage secureStorage = SecureStorage();
  int _currentIndex = 0;
  final List<Widget> _interfaces = [
    const ListCommands(),
    const Menu(),
    ListNotifications(),
    const Settings(),
  ];
  String? nbNotifications;
  StreamSubscription<void>? _streamSubscription;
  Future<void> getNbNewNotiofications() async {
    const interval = Duration(seconds: 15);

    _streamSubscription=Stream.periodic(interval).listen((_) async {
      var _nbNotifications = await secureStorage.readData(nbNewNotifications);

      setState(() {
        nbNotifications = _nbNotifications;
      });
    });
  }
  @override
  void dispose() {
    _streamSubscription!.cancel();
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
          content:  Text(AppLocalizations.of(context)!.confirmDialogMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () =>     SystemNavigator.pop(),
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
        selectedItemColor:
        orange, // sets the label color of the selected item to blue
        unselectedItemColor: gray,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items:  [
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded), label: "",),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: ""),
          BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.notifications_rounded),
                  nbNotifications != null && nbNotifications!="0"
                      ? Positioned(
                      right: -1,
                      top: 2,
                      child: Stack(
                        children: [
                          Icon(
                            Icons.brightness_1,
                            color: Colors.red,
                            size: 14,
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                nbNotifications.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ))
                      : SizedBox(),
                ],
              ),
              label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: "")
        ],
        currentIndex: _currentIndex,
        onTap: (value) async {
          setState(() {
            _currentIndex = value;
          });
          if(_currentIndex==2){
            await secureStorage.deleteData(nbNewNotifications);
            setState(() {
              nbNotifications=null;
            });
          }
        },
      ),
    ));
  }
}
