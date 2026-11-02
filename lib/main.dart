import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talabatfresh/app_entry_page.dart';
import 'package:talabatfresh/data/themes_data.dart';
import 'package:talabatfresh/features/home/providers/customer_home_provider.dart';
import 'package:talabatfresh/features/marketplace/providers/cart_provider.dart';
import 'package:talabatfresh/features/marketplace/providers/marketplace_provider.dart';
import 'package:talabatfresh/features/marketplace/providers/place_order_provider.dart';
import 'package:talabatfresh/features/part_requests/providers/part_request_provider.dart';
import 'package:talabatfresh/features/profile/providers/profile_provider.dart';
import 'package:talabatfresh/features/repair/providers/repair_provider.dart';
import 'package:talabatfresh/features/roadside/providers/roadside_provider.dart';
import 'package:talabatfresh/features/vehicles/providers/vehicle_provider.dart';
import 'package:talabatfresh/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'data/local/AppDatabaseHelper.dart';
import 'data/local/cache_helper.dart';
import 'data/local/dbTablesHelpers/NotificationDb.dart';
import 'data/local/dbTablesHelpers/dbModels/db_models.dart';
import 'startup_gate.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(StartupGate(initialize: initializeApp, builder: (_) => const App()));
}

Future<void> initializeApp() async {
  await CacheHelper.init();
  if (kIsWeb) return;
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  await AppDatabaseHelper().database;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<String>? _tokenSubscription;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _messageSubscription = FirebaseMessaging.onMessage.listen((
        message,
      ) async {
        try {
          if (message.data.isNotEmpty) await _showNotification(message);
        } catch (error) {
          debugPrint('Unable to display notification: $error');
        }
      });
      _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
        (_) {
          unawaited(_subscribeToNotifications());
        },
        onError: (Object error) {
          debugPrint('Unable to refresh notification token: $error');
        },
      );
      unawaited(_configureNotifications());
    }
  }

  Future<void> _configureNotifications() async {
    try {
      await _initializeLocalNotifications();
      await FirebaseMessaging.instance.requestPermission();
      await _subscribeToNotifications();
    } catch (error) {
      // Notification failures must not prevent the app from opening.
      debugPrint('Unable to configure notifications: $error');
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _tokenSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerHomeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RoadsideProvider()),
        ChangeNotifierProvider(create: (_) => RepairProvider()),
        ChangeNotifierProvider(create: (_) => PlaceOrderProvider()),
        ChangeNotifierProvider(create: (_) => PartRequestProvider()),
      ],
      child: GetMaterialApp(
        defaultTransition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 500),
        debugShowCheckedModeBanner: false,
        title: 'Qotomoto',
        home: const AppEntryPage(),
        theme: lightModeTheme,
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _initializeLocalNotifications();
  await _showNotification(message);
}

Future<void> _initializeLocalNotifications() async {
  const settings = InitializationSettings(
    android: AndroidInitializationSettings(
      '@drawable/wheely_icon_notify_trans',
    ),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );
  await flutterLocalNotificationsPlugin.initialize(settings);
}

Future<void> _subscribeToNotifications() async {
  try {
    final messaging = FirebaseMessaging.instance;
    if ((Platform.isIOS || Platform.isMacOS) &&
        await messaging.getAPNSToken() == null) {
      return;
    }
    await messaging.subscribeToTopic('koshy');
  } catch (error) {
    debugPrint('Unable to subscribe to notifications: $error');
  }
}

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  if (Platform.isAndroid) {
    // Only needed on Android 13+
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('User denied notification permission');
    } else {
      debugPrint('Notification permission not determined or restricted');
    }
  }
}

Future<void> requestNotificationPermissionManual() async {
  var status = await Permission.notification.status;
  if (!status.isGranted) {
    status = await Permission.notification.request();
    if (status.isGranted) {
      debugPrint('Notification permission granted');
    } else {
      debugPrint('Notification permission denied');
    }
  }
}

Future<void> _showNotification(RemoteMessage message) async {
  final data = message.data;
  final title = data['head'] ?? 'No Title';
  final body = data['desc'] ?? 'No Description';

  final notificationDb = NotificationDb();
  await notificationDb.insertItem(
    NotificationItem(
      // id: product.id,
      title: title,
      description: body,
      action: '',
      topic: '',
    ),
  );

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'fcm_data_channel',
    'Data Notifications',
    channelDescription: 'Channel for data-only FCM messages',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    title,
    body,
    notificationDetails,
    payload: data['url'], // you can handle it on tap
  );
}
