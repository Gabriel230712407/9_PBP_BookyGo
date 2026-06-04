import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/notifications/models/app_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService._();

  static const _enabledKeyPrefix = 'bookygo.notifications.enabled';
  static const _itemsKeyPrefix = 'bookygo.notifications.items';

  static Future<bool> isEnabled(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey(session)) ?? false;
  }

  static Future<void> setEnabled(
    AuthSession session,
    bool enabled,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey(session), enabled);
  }

  static Future<List<AppNotification>> getNotifications(
    AuthSession session,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_itemsKey(session)) ?? const [];

    return rawItems
        .map(AppNotification.fromStorageValue)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<int> getUnreadCount(AuthSession session) async {
    final items = await getNotifications(session);
    return items.where((item) => !item.isRead).length;
  }

  static Future<void> addNotification(
    AuthSession session, {
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final items = await getNotifications(session);
    final nextItems = [
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        message: message,
        createdAt: DateTime.now(),
        type: type,
        data: data,
      ),
      ...items,
    ];
    await _saveNotifications(session, nextItems.take(40).toList());
  }

  static Future<void> markAllAsRead(AuthSession session) async {
    final items = await getNotifications(session);
    final updated = items.map((item) => item.copyWith(isRead: true)).toList();
    await _saveNotifications(session, updated);
  }

  static Future<void> markAsRead(AuthSession session, String notifId) async {
    final items = await getNotifications(session);
    final updated = items.map((item) {
      return item.id == notifId ? item.copyWith(isRead: true) : item;
    }).toList();
    await _saveNotifications(session, updated);
  }

  static Future<void> maybeGenerateReviewNotification(
    AuthSession session, {
    required String pemesananId,
    required String hotelNama,
    required String kodeBooking,
    required DateTime tglCheckout,
  }) async {
    if (!await isEnabled(session)) return;

    // Jangan buat duplikat
    final items = await getNotifications(session);
    final alreadyExists = items.any((item) =>
        item.type == 'review' &&
        item.data?['pemesanan_id'] == pemesananId);
    if (alreadyExists) return;

    // Hanya generate kalau sudah lewat checkout
    if (DateTime.now().isBefore(tglCheckout)) return;

    await addNotification(
      session,
      title: 'How was your stay?',
      message: 'You just checked out from $hotelNama. Share your experience!',
      type: 'review',
      data: {
        'pemesanan_id': pemesananId,
        'hotel_nama': hotelNama,
        'kode_booking': kodeBooking,
      },
    );
  }

  static Future<void> seedAfterNotificationEnabled(AuthSession session) async {
    final items = await getNotifications(session);
    if (items.isNotEmpty) {
      return;
    }

    await addNotification(
      session,
      title: 'Notifications Enabled',
      message: 'You will now receive booking updates and useful reminders.',
      type: 'system',
    );
    await addNotification(
      session,
      title: 'Welcome to BookyGo',
      message: 'Discover stays, save favorites, and keep your trips organized.',
      type: 'welcome',
    );
  }

  static Future<void> maybeLogLoginActivity(AuthSession session) async {
    if (!await isEnabled(session)) {
      return;
    }

    await addNotification(
      session,
      title: 'Signed In',
      message: 'Your account was signed in successfully.',
      type: 'activity',
    );
  }

  static Future<void> maybeLogProfileUpdate(AuthSession session) async {
    if (!await isEnabled(session)) {
      return;
    }

    await addNotification(
      session,
      title: 'Profile Updated',
      message: 'Your profile details were updated successfully.',
      type: 'profile',
    );
  }

  static Future<void> maybeLogLocationPreference(AuthSession session) async {
    if (!await isEnabled(session)) {
      return;
    }

    await addNotification(
      session,
      title: 'Location Preference Saved',
      message: 'Your location access preference has been saved for BookyGo.',
      type: 'location',
    );
  }

  static Future<void> _saveNotifications(
    AuthSession session,
    List<AppNotification> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _itemsKey(session),
      items.map((item) => item.toStorageValue()).toList(),
    );
  }

  static Future<void> deleteNotification(AuthSession session, String notifId) async {
    final items = await getNotifications(session);
    final updated = items.where((item) => item.id != notifId).toList();
    await _saveNotifications(session, updated);
  }

  static String _enabledKey(AuthSession session) {
    return '$_enabledKeyPrefix.${session.user.id}';
  }

  static String _itemsKey(AuthSession session) {
    return '$_itemsKeyPrefix.${session.user.id}';
  }
}
