import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/api_config.dart';
import 'package:frontend/core/auth/services/auth_storage.dart';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const String _channelId   = 'bookygo_high_importance';
const String _channelName = 'BookyGo Notifications';
const String _channelDesc = 'Booking updates and reminders from BookyGo';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _showLocalNotification(message);
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  await _localNotifications.show(
    notification.hashCode,
    notification.title,
    notification.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    payload: jsonEncode(message.data),
  );
}

class FcmService {
  FcmService._();

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Notif tapped: ${response.payload}');
      },
    );

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    final token = await messaging.getToken();
    if (token != null) {
      debugPrint('📱 FCM Token: $token');
      await _saveFcmToken(token);
    } else {
      debugPrint('❌ FCM Token NULL');
    }
    messaging.onTokenRefresh.listen(_saveFcmToken);
  }

  static Future<void> _saveFcmToken(String token) async {
    try {
      final session = await AuthStorage.getSession();

      debugPrint('🔑 Session: ${session?.token}');
      debugPrint('📱 FCM Token: $token');
      debugPrint('🌐 URL: ${ApiConfig.baseUrl}/fcm-token');

      if (session == null) {
        debugPrint('❌ Session null - belum login saat token disimpan');
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${session.token}',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }
}
