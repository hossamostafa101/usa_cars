import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_paymob/flutter_paymob.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talabatfresh/app_entry_page.dart';
import 'package:talabatfresh/data/themes_data.dart';
import 'package:talabatfresh/features/home/providers/customer_home_provider.dart';
import 'package:talabatfresh/features/home/providers/home_provider.dart';
import 'package:talabatfresh/features/marketplace/providers/cart_provider.dart';
import 'package:talabatfresh/features/marketplace/providers/marketplace_provider.dart';
import 'package:talabatfresh/features/marketplace/providers/place_order_provider.dart';
import 'package:talabatfresh/features/part_requests/providers/part_request_provider.dart';
import 'package:talabatfresh/features/profile/providers/profile_provider.dart';
import 'package:talabatfresh/features/repair/providers/repair_provider.dart';
import 'package:talabatfresh/features/roadside/providers/roadside_provider.dart';
import 'package:talabatfresh/features/vehicles/providers/vehicle_provider.dart';
import 'package:talabatfresh/pages/home_page.dart';
import 'package:talabatfresh/pages/splash_page.dart';
import 'package:talabatfresh/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'data/local/AppDatabaseHelper.dart';
import 'data/local/cache_helper.dart';
import 'data/local/dbTablesHelpers/NotificationDb.dart';
import 'data/local/dbTablesHelpers/dbModels/db_models.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  if (kIsWeb) {
    // 🔹 مؤقتًا على الويب: ما تعملش DB ولا Messaging
    // لو Firebase لسه مش متظبّط للويب، خليه متعطّل خالص
    // ولو ظبطناه بعدين هنغير السطر ده ونضيف options
    // مثال بعد ما نجهّز firebase_options.dart:
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    runApp(const App());
    return;
  }
  await Firebase.initializeApp();
  final dbHelper = AppDatabaseHelper();
  await dbHelper.database;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.subscribeToTopic('koshy');
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@drawable/wheely_icon_notify_trans');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);

  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      requestNotificationPermission();

      FirebaseMessaging.onMessage.listen((message) {
        if (message.data.isNotEmpty) {
          _showNotification(message);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        // Optional: Handle navigation
      });
    }
  }
  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      await Permission.notification.request();
    }
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
        ChangeNotifierProvider(
          create: (_) => PartRequestProvider(),
        ),
      ],
      child: GetMaterialApp(
        defaultTransition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 500),
        debugShowCheckedModeBanner: false,
        title: 'usa cars',
        home: const AppEntryPage(),
        theme: lightModeTheme,
      ),
    );
  }
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("XXXXX Background message: ${message.messageId}");
  _showNotification(message);
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
      print('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('User denied notification permission');
    } else {
      print('Notification permission not determined or restricted');
    }
  }
}

Future<void> requestNotificationPermissionManual() async {
  var status = await Permission.notification.status;
  if (!status.isGranted) {
    status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
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
      title: data['head'],
      description: data['desc'],
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

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    title,
    body,
    notificationDetails,
    payload: data['url'], // you can handle it on tap
  );
}