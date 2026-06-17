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

const String _channelId = 'bookygo_alerts_v2';
const String _channelName = 'BookyGo Notifications';
const String _channelDesc = 'Booking updates and reminders from BookyGo';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _showLocalNotification(message);
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final title = notification?.title ?? message.data['title']?.toString();
  final body = notification?.body ?? message.data['body']?.toString();
  if (title == null && body == null) return;

  await _localNotifications.show(
    message.messageId?.hashCode ?? message.data.hashCode,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: '@drawable/ic_notification',
      ),
    ),
    payload: jsonEncode(message.data),
  );
}

class FcmService {
  FcmService._();

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    debugPrint('LOCAL_NOTIFICATION_SHOW title=$title data=$data');
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/ic_notification',
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Notif tapped: ${response.payload}');
        _handleNotificationData(response.payload);
      },
    );

    final androidLocalNotifications = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidLocalNotifications?.createNotificationChannel(androidChannel);
    await androidLocalNotifications?.requestNotificationsPermission();

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await messaging.setForegroundNotificationPresentationOptions(
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

    if ((type == 'review' || type == 'review_reminder') &&
        pemesananId != null) {
      debugPrint('🧭 Condition matched, fetching booking...');
      try {
        final booking = await BookingService().fetchBookingById(
          int.parse(pemesananId.toString()),
        );
        debugPrint('🧭 Booking fetched: ${booking.id}');

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ReviewFormPage(
              booking: booking,
              isEditing: booking.hasReview,
            ),
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
