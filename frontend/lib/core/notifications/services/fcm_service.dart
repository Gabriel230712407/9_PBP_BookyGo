import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/core/auth/services/auth_storage.dart';
import 'package:frontend/core/constants/api_config.dart';
import 'package:frontend/features/mybook/services/booking_service.dart';
import 'package:frontend/features/reviews/pages/review_form.dart';
import 'package:frontend/main.dart';
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const String _channelId = 'bookygo_high_importance';
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
        icon: '@drawable/ic_notification',
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
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
        _handleNotificationData(response.payload);
      },
    );

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Notification opened app: ${message.data}');
      _navigateFromData(message.data);
    });

    try {
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App opened from terminated state: ${initialMessage.data}');
        _navigateFromData(initialMessage.data);
      }
    } catch (e) {
      debugPrint('FCM initial message unavailable: $e');
    }

    try {
      final token = await messaging.getToken();
      if (token != null) {
        debugPrint('FCM token: $token');
        await _saveFcmToken(token);
      } else {
        debugPrint('FCM token is null');
      }
    } catch (e) {
      debugPrint('FCM token unavailable: $e');
    }

    messaging.onTokenRefresh.listen(
      _saveFcmToken,
      onError: (Object error) {
        debugPrint('FCM token refresh failed: $error');
      },
    );
  }

  static void _handleNotificationData(String? payload) {
    if (payload == null) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
    }
  }

  static Future<void> _navigateFromData(Map<String, dynamic> data) async {
    debugPrint('Navigate from notification data: $data');

    final type = data['type'];
    final pemesananId = data['pemesanan_id'];

    if (type == 'review' && pemesananId != null) {
      try {
        final booking = await BookingService().fetchBookingById(
          int.parse(pemesananId.toString()),
        );

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ReviewFormPage(booking: booking),
          ),
        );
      } catch (e) {
        debugPrint('Failed to load booking for review: $e');
      }
    }
  }

  static Future<void> _saveFcmToken(String token) async {
    try {
      final session = await AuthStorage.getSession();

      debugPrint('Session token: ${session?.token}');
      debugPrint('FCM token to save: $token');
      debugPrint('Save URL: ${ApiConfig.baseUrl}/fcm-token');

      if (session == null) {
        debugPrint('Session is null, skipping FCM token save');
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

      debugPrint('FCM save response status: ${response.statusCode}');
      debugPrint('FCM save response body: ${response.body}');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }
}
