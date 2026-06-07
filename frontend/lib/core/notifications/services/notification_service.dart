import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/notifications/models/app_notification.dart';
import 'package:frontend/core/constants/api_config.dart';

class NotificationService {
  NotificationService._();

  static Map<String, String> _headers(AuthSession session) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${session.token}',
  };

  // ─── CORE ──────────────────────────────────────────────────────────────────

  static Future<List<AppNotification>> getNotifications(
    AuthSession session,
  ) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: _headers(session),
      );
      if (res.statusCode != 200) return [];
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<int> getUnreadCount(AuthSession session) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/unread-count'),
        headers: _headers(session),
      );
      if (res.statusCode != 200) return 0;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return (json['count'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> markAllAsRead(AuthSession session) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/mark-all-read'),
        headers: _headers(session),
      );
    } catch (_) {}
  }

  static Future<void> markAsRead(AuthSession session, String notifId) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$notifId/read'),
        headers: _headers(session),
      );
    } catch (_) {}
  }

  static Future<void> deleteNotification(
    AuthSession session,
    String notifId,
  ) async {
    try {
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$notifId'),
        headers: _headers(session),
      );
    } catch (_) {}
  }

  // ─── ENABLED STATE ─────────────────────────────────────────────────────────

  static Future<bool> isEnabled(AuthSession session) async => true;
  static Future<void> setEnabled(AuthSession session, bool enabled) async {}

  // ─── SEED / WELCOME ────────────────────────────────────────────────────────

  static Future<void> seedAfterNotificationEnabled(AuthSession session) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/seed-welcome'),
        headers: _headers(session),
      );
    } catch (_) {}
  }

  // ─── ACTIVITY LOGGING ──────────────────────────────────────────────────────

  static Future<void> maybeLogLoginActivity(AuthSession session) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/log-login'),
        headers: _headers(session),
      );
    } catch (_) {}
  }

  static Future<void> maybeLogProfileUpdate(AuthSession session) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/log-profile-update'),
        headers: _headers(session),
      );
    } catch (_) {}
  }

  static Future<void> maybeLogLocationPreference(AuthSession session) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/log-location'),
        headers: _headers(session),
      );
    } catch (_) {}
  }

  // ─── REVIEW NOTIFICATIONS ──────────────────────────────────────────────────
  // FIX: kirim pemesanan_id ke backend supaya backend bisa cek duplikat

  static Future<void> maybeGenerateReviewNotification(
    AuthSession session, {
    required String pemesananId,
    required String hotelNama,
    required String kodeBooking,
    required DateTime tglCheckout,
  }) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/generate-review'),
        headers: _headers(session),
        body: jsonEncode({
          'pemesanan_id': pemesananId,
          'hotel_nama':   hotelNama,
          'kode_booking': kodeBooking,
          'tgl_checkout': tglCheckout.toIso8601String(),
        }),
      );
    } catch (_) {}
  }
}
