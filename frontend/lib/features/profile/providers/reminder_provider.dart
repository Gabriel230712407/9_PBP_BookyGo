import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }
}