import 'dart:io';

import 'package:diary_fe/env/env.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ApiService apiService = ApiService();
  String? token;
  static final NotificationService _instance = NotificationService._internal();

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }
  void initialize() {
    _initFCM();
    _configureLocalNotification();
    _configureFCMHandlers();
    _getToken();
    _tokenRefreshListener();
  }

  Future<void> _initFCM() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  void _configureLocalNotification() {
    FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            'high_importance_channel', 'high_importance_notification',
            importance: Importance.max));
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    FlutterLocalNotificationsPlugin().initialize(initializationSettings);
  }

  void _configureFCMHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          "onMessage: ${message.notification?.title}, ${message.notification?.body}");
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          "onMessageOpenedApp: ${message.notification?.title}, ${message.notification?.body}");
      _showNotification(message);
    });
  }

  void _showNotification(RemoteMessage message) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
      'high_importance_channel',
      'high_importance_notification',
      importance: Importance.max,
    ));
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      FlutterLocalNotificationsPlugin().show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
      );
    }
  }

  void _getToken() async {
    String? initToken;
    if (kIsWeb) {
      initToken =
          await FirebaseMessaging.instance.getToken(vapidKey: Env.vapidKey);

      if (initToken == null || initToken.isEmpty) {
        return;
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      initToken = await FirebaseMessaging.instance.getToken();
      if (initToken == null || initToken.isEmpty) {
        return;
      }
    }
    debugPrint("FCM Token: $initToken");
    // Save the token to the server if needed
    token = initToken;
  }

  void _tokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token Refreshed: $newToken");
      token = newToken;
      tokenRegister();
    }).onError((err) {
      // Error getting token.
    });
  }

  Future<void> tokenRegister() async {
    try {
      if (kIsWeb) {
        if (token == null || token!.isEmpty) {
          return;
        }
        await apiService.post("/api/notification", data: {
          "platform": "WEB",
          "token": token,
        });
      } else if (Platform.isAndroid || Platform.isIOS) {
        if (token == null || token!.isEmpty) {
          return;
        }
        await apiService.post("/api/notification", data: {
          "platform": "ANDROID",
          "token": token,
        });
      }
    } catch (e) {
      if (e is DioException) {
        switch (e.response?.statusCode) {
          case 409:
            Response response = await tokenDelete();
            if (response.statusCode == 200) {
              tokenRegister();
              return;
            }
            break;
          default:
        }
      }
      debugPrint(e.toString());
    }
  }

  Future<Response> tokenDelete() async {
    Response response =
        await apiService.delete("/api/notification?token=$token");
    return response;
  }
}
