import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/auth/services/auth_storage.dart';
import 'package:frontend/core/constants/api_config.dart';
import 'package:http/http.dart' as http;

class FcmTokenService {
  FcmTokenService._();

  static const _syncTimeout = Duration(seconds: 8);

  static Future<void> sync(AuthSession session) async {
    try {
      final token = await FirebaseMessaging.instance
          .getToken()
          .timeout(_syncTimeout);
      if (token == null) {
        return;
      }

      await syncToken(session, token);
    } catch (_) {}
  }

  static Future<void> syncForCurrentSession(String token) async {
    final session = await AuthStorage.getSession();
    if (session == null) {
      return;
    }

    await syncToken(session, token);
  }

  static Future<void> syncToken(AuthSession session, String token) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${session.token}',
        },
        body: jsonEncode({'fcm_token': token}),
      ).timeout(_syncTimeout);
    } catch (_) {}
  }
}
