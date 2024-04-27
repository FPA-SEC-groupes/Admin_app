import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hello_way/navigation/manager_bottom_navigation.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/services/network_service.dart';
import 'package:hello_way/services/push_notification_service.dart';

import 'package:hello_way/utils/routes.dart';
import 'package:hello_way/view/add_user.dart';
import 'package:hello_way/view/admin/list_moderators.dart';
import 'package:hello_way/view/change_password.dart';
import 'package:hello_way/view/forget_password.dart';
import 'package:hello_way/view/login.dart';
import 'package:hello_way/view/manager/add_party_event.dart';
import 'package:hello_way/view/manager/add_primary_material.dart';
import 'package:hello_way/view/manager/add_product.dart';
import 'package:hello_way/view/manager/add_space.dart';
import 'package:hello_way/view/manager/list_events.dart';
import 'package:hello_way/view/manager/space.dart';

import 'package:hello_way/view/manager/list_waiters.dart';
import 'package:hello_way/view/manager/list_zones.dart';
import 'package:hello_way/view/manager/calendar_events.dart';
import 'package:hello_way/view/manager/space_location.dart';
import 'package:hello_way/view/manager/stock.dart';
import 'package:hello_way/view/profile.dart';
import 'package:hello_way/view/splash_screen.dart';
import 'package:hello_way/view_model/language_provider.dart';
import 'package:provider/provider.dart';

import 'l10n/l10n.dart';
import 'navigation/waiter_bottom_navigation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the notification plugin
  await _initializeNotifications();


  runApp(MyApp());
}

Future<void> _initializeNotifications() async {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon'); // Replace 'app_icon' with your app icon name in the drawable folder.

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}


class MyApp extends StatelessWidget {
  // Create an instance of FlutterLocalNotificationsPlugin

  final Locale initialLocale;
  late Locale _locale;

  MyApp({Key? key, this.initialLocale = const Locale('en')})
      : super(key: key) {
    _locale = initialLocale;
  }

  void updateLocale(Locale newLocale) {
    _locale = newLocale;
  }


  @override
  Widget build(BuildContext context) {
    final pushNotificationService = PushNotificationService(
      flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
      context: context, // Provide the context from your widget tree
    );

    pushNotificationService.init();
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: pushNotificationService),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        StreamProvider<NetworkStatus>(
        create: (_) => NetworkStatusService().networkStatusController.stream,
          initialData: NetworkStatus.Online,
          ),
          ],
          child: Consumer<LanguageProvider>(
              builder: (_, languageProvider, __) { return MaterialApp(
        theme: ThemeData().copyWith(
          colorScheme: ThemeData().colorScheme.copyWith(
            primary:orange,

          ),
        ),
        supportedLocales: L10n.all,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: languageProvider.locale,

      title: 'Hello Way',
        routes: {
        splashScreenRoute: (context) {
        return
          SplashScreen();
        },
        loginRoute: (context) {
        return
          const Login();
        },
          managerBottomNavigationRoute: (context) {
            return
              const ManagerBottomNavigation();
          },
        listWaitersRoute: (context) {
            return
              const ListWaiters();
          },
        addWaiterRoute: (context) {
            return
               AddUser();
          },

          addProductRoute: (context) {
            return
              const AddProduct();
          },


       changePasswordRoute: (context) {
         return
           const ChangePassword();
       },

          listZonesRoute: (context) {
            return
              ListZones();
          },
          addSpaceRoute: (context) {
            return
              const AddSpace();
          },
          detailsSpaceRoute : (context) {
            return
              DetailsSpace();
          },
          waiterBottomNavigationRoute: (context) {
            return
              WaiterBottomNavigation();
          },
          profileRoute: (context) {
            return
              Profile();
          },
          listEventsRoute: (context) {
            return
              ListEvents();
          },
          calendarEventsRoute: (context) {
            return
              CalendarEvents();
          },
          addNewPartyEventRoute: (context) {
            return
              AddPartyEvent();
          },
          addPrimaryMaterialRoute: (context) {
            return
              AddPrimaryMaterial();
          },
          stockRoute: (context) {
            return
              Stock();
          },
          forgetPasswordRoute: (context) {
            return
              ForgetPassword();
          },
          listModeratorsRoute: (context) {
            return
              ListModerators();
          },
          spaceLocationRoute: (context) {
            return
              SpaceLocation();
          },

      }
    );

        }));
  }

}

