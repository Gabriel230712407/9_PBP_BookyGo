import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/api_config.dart';
import 'package:frontend/core/auth/services/auth_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/features/mybook/services/booking_service.dart';
import 'package:frontend/features/reviews/pages/review_form.dart';

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
      debugPrint('🔔 Notif opened app: ${message.data}');
      _navigateFromData(message.data);
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🔔 App opened from terminated: ${initialMessage.data}');
      _navigateFromData(initialMessage.data);
    }

    final token = await messaging.getToken();
    if (token != null) {
      debugPrint('📱 FCM Token: $token');
      await _saveFcmToken(token);
    } else {
      debugPrint('❌ FCM Token NULL');
    }
    messaging.onTokenRefresh.listen(_saveFcmToken);
  }

  static void _handleNotificationData(String? payload) {
    if (payload == null) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (e) {
      debugPrint('❌ Error parsing payload: $e');
    }
  }

  static Future<void> _navigateFromData(Map<String, dynamic> data) async {
    debugPrint('🧭 _navigateFromData called with: $data');
    
    final type = data['type'];
    final pemesananId = data['pemesanan_id'];
    
    debugPrint('🧭 type: $type, pemesananId: $pemesananId');
    debugPrint('🧭 navigatorKey.currentState: ${navigatorKey.currentState}');

    if (type == 'review' && pemesananId != null) {
      debugPrint('🧭 Condition matched, fetching booking...');
      try {
        final booking = await BookingService().fetchBookingById(
          int.parse(pemesananId.toString()),
        );
        debugPrint('🧭 Booking fetched: ${booking.id}');

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ReviewFormPage(booking: booking),
          ),
        );
        debugPrint('🧭 Navigation pushed');
      } catch (e) {
        debugPrint('❌ Failed to load booking for review: $e');
      }
    } else {
      debugPrint('🧭 Condition NOT matched - type or pemesananId mismatch');
    }
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