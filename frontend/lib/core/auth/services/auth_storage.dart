import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  AuthStorage._();

  static const _sessionKey = 'bookygo.auth.session';
  static const _permissionCompletedKeyPrefix = 'bookygo.permission.completed';

  static Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, session.toStorageValue());
  }

  static Future<AuthSession?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rawSession = prefs.getString(_sessionKey);

    if (rawSession == null || rawSession.isEmpty) {
      return null;
    }

    try {
      return AuthSession.fromStorageValue(rawSession);
    } catch (_) {
      await prefs.remove(_sessionKey);
      return null;
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  static Future<bool> isPermissionFlowCompleted(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionKey(userKey)) ?? false;
  }

  static Future<void> markPermissionFlowCompleted(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionKey(userKey), true);
  }

  static String _permissionKey(String userKey) {
    return '$_permissionCompletedKeyPrefix.$userKey';
  }

  static const _fingerprintEnabledKey = 'bookygo.auth.fingerprint_enabled';

  static Future<bool> isFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fingerprintEnabledKey) ?? false;
  }

  static Future<void> setFingerprintEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fingerprintEnabledKey, value);
  }
}
