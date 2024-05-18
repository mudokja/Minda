import 'dart:developer';
import 'package:diary_fe/env/env.dart';
import 'package:diary_fe/firebase_options.dart';
import 'package:diary_fe/src/models/notification.dart';
import 'package:diary_fe/src/screens/intro_page.dart';
import 'package:diary_fe/src/screens/pages.dart';
import 'package:diary_fe/src/services/notification_service.dart';
import 'package:diary_fe/src/screens/splash_screen.dart'; // 스플래시 화면 import
import 'package:diary_fe/src/services/user_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/services/services_initializer.dart'; // setup.dart 파일 import

// main.dart 파일
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print("백그라운드 메시지 처리.. ${message.notification!.body!}");
// Handle background message
}
// Future<void> _initFCMToken() async {
//   FirebaseMessaging messaging= FirebaseMessaging.instance;
//
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//   debugPrint('User granted permission: ${settings.authorizationStatus}');
//   FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingBackgroundHandler);
//
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//
//     if (notification != null) {
//       FlutterLocalNotificationsPlugin().show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'high_importance_channel',
//             'high_importance_notification',
//             importance: Importance.max,
//           ),
//         ),
//       );
//     }
//   });
//   String? fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: Env.vapidKey);
//   // 여기에서 _fcmToken을 사용하여 필요한 작업을 수행할 수 있습니다.
//   log(fcmToken!); // 로거를 사용하여 토큰을 출력
// }

// void initializeNotification() async {
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(const AndroidNotificationChannel(
//           'high_importance_channel', 'high_importance_notification',
//           importance: Importance.max));
//
//   await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
//     android: AndroidInitializationSettings("@mipmap/ic_launcher"),
//   ));
//
//
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics.instance.logAppOpen();
  NotificationService().initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: Env.kakaoApiKey,
    javaScriptAppKey: Env.kakaoJSKey,
  );
  runApp(initializeDiaryProvider());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Minda",
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return const Scaffold(
            resizeToAvoidBottomInset: false,
            body: SplashScreen(),
          );
        },
      ), // 스플래시 화면으로 설정
    );
  }
}
