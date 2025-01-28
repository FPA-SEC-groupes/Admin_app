import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:hello_way/view/waiter/listShift.dart';
import 'package:hello_way/view_model/language_provider.dart';
import 'package:provider/provider.dart';
import 'l10n/l10n.dart';
import 'navigation/waiter_bottom_navigation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initializeNotifications();
  runApp(MyApp());
}

Future<void> _initializeNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  late Locale _locale;

  MyApp({Key? key, this.initialLocale = const Locale('en')}) : super(key: key) {
    _locale = initialLocale;
  }

  void updateLocale(Locale newLocale) {
    _locale = newLocale;
  }

  @override
  Widget build(BuildContext context) {
    final pushNotificationService = PushNotificationService(
      flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
      context: context,
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
        builder: (_, languageProvider, __) {
          return MaterialApp(
            navigatorObservers: [routeObserver],
            theme: ThemeData().copyWith(
              colorScheme: ThemeData().colorScheme.copyWith(primary: orange),
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
              splashScreenRoute: (context) => SplashScreen(),
              loginRoute: (context) => const Login(),
              managerBottomNavigationRoute: (context) => const ManagerBottomNavigation(),
              listWaitersRoute: (context) => const ListWaiters(),
              addWaiterRoute: (context) => AddUser(),
              addProductRoute: (context) => const AddProduct(),
              changePasswordRoute: (context) => const ChangePassword(),
              listZonesRoute: (context) => ListZones(),
              addSpaceRoute: (context) => const AddSpace(),
              detailsSpaceRoute: (context) => DetailsSpace(),
              waiterBottomNavigationRoute: (context) => WaiterBottomNavigation(),
              WaiterShift: (context) => WaiterShiftPage(),
              profileRoute: (context) => Profile(),
              listEventsRoute: (context) => ListEvents(),
              calendarEventsRoute: (context) => CalendarEvents(),
              addNewPartyEventRoute: (context) => AddPartyEvent(),
              addPrimaryMaterialRoute: (context) => AddPrimaryMaterial(),
              stockRoute: (context) => Stock(),
              forgetPasswordRoute: (context) => ForgetPassword(),
              listModeratorsRoute: (context) => ListModerators(),
              spaceLocationRoute: (context) => SpaceLocation(),
            },
          );
        },
      ),
    );
  }
}
