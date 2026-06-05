import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/auth/services/auth_service.dart';
import 'package:frontend/core/notifications/services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  static const _keyEmail = 'reminder_email';
  static const _keyNotification = 'reminder_notification';

  bool emailEnabled = false;
  bool notificationEnabled = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    emailEnabled = prefs.getBool(_keyEmail) ?? false;
    notificationEnabled = prefs.getBool(_keyNotification) ?? false;
    notifyListeners();
  }

  Future<void> setEmail(bool value) async {
    emailEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEmail, value);
  }

  Future<void> setNotification(bool value) async {
    notificationEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotification, value);

    final session = await AuthService.currentSession();
    if (session != null) {
      await NotificationService.setEnabled(session, value);
      if (value) {
        await NotificationService.seedAfterNotificationEnabled(session);
      }
    }
  }
}