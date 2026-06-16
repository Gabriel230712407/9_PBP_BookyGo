import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/auth/models/auth_user.dart';
import 'package:frontend/core/auth/services/auth_storage.dart';
import 'package:frontend/core/constants/api_config.dart';
import 'package:frontend/core/notifications/services/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static const _requestTimeout = Duration(seconds: 35);

  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _post(
      '/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    final session = _parseAuthResponse(response);
    await AuthStorage.saveSession(session);
    await NotificationService.maybeLogLoginActivity(session);

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await _saveFcmTokenToServer(session.token, fcmToken);
    }
    return session;
  }

  static Future<void> _saveFcmTokenToServer(String authToken, String fcmToken) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );
    } catch (_) {}
  }

  static Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? googleUid,
    String? photoUrl,
  }) async {
    final response = await _post(
      '/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
        if (googleUid != null && googleUid.isNotEmpty) 'google_uid': googleUid,
        if (photoUrl != null && photoUrl.isNotEmpty) 'foto': photoUrl,
      },
    );

    final session = _parseAuthResponse(response);
    await AuthStorage.saveSession(session);
    await NotificationService.maybeLogLoginActivity(session);

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await _saveFcmTokenToServer(session.token, fcmToken);
    }
    return session;
  }

  static Future<GoogleAuthResult> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google Sign-In canceled.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await _post(
        '/auth/google',
        body: {
          'id_token': googleAuth.idToken ?? '',
        },
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      final registered = data['registered'] == true;

      if (!registered) {
        final profile = data['profile'] as Map<String, dynamic>;
        return GoogleAuthResult.unregistered(
          profile: GoogleRegistrationProfile(
            name: profile['name'] as String? ?? '',
            email: profile['email'] as String? ?? '',
            photoUrl: profile['photo'] as String?,
            googleUid: profile['google_uid'] as String?,
          ),
          message: _normalizeMessage(decoded['message'] as String? ?? 'This Google account is not registered yet.'),
        );
      }

      final session = _parseAuthResponse(response);
      await AuthStorage.saveSession(session);
      await NotificationService.maybeLogLoginActivity(session);

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _saveFcmTokenToServer(session.token, fcmToken);
      }

      return GoogleAuthResult.registered(session: session);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google Sign-In failed: ${e.toString()}');
    }
  }

  static Future<AuthSession?> restoreSession() async {
    final localSession = await AuthStorage.getSession();
    if (localSession == null) {
      return null;
    }

    try {
      final response = await http
          .get(
            _uri('/me'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${localSession.token}',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        await AuthStorage.clearSession();
        return null;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final user = AuthUser.fromJson(decoded['data'] as Map<String, dynamic>);

      final refreshedSession = AuthSession(
        token: localSession.token,
        user: user,
      );

      await AuthStorage.saveSession(refreshedSession);
      return refreshedSession;
    } catch (_) {
      await AuthStorage.clearSession();
      return null;
    }
  }

  static Future<AuthSession?> currentSession() {
    return AuthStorage.getSession();
  }

  static Future<void> logout() async {
    final session = await AuthStorage.getSession();

    if (session != null) {
      try {
        await http
            .post(
              _uri('/logout'),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer ${session.token}',
              },
            )
            .timeout(_requestTimeout);
      } catch (_) {
      }
    }

    await AuthStorage.clearSession();
  }

  static Future<void> deleteAccount() async {
    final session = await AuthStorage.getSession();

    if (session == null) {
      throw const AuthException(
        'Your session was not found. Please sign in again.',
      );
    }

    try {
      final response = await http
          .delete(
            _uri('/account'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${session.token}',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildAuthException(response.body);
      }

      await AuthStorage.clearSession();
    } on SocketException {
      throw AuthException(
        'Cannot reach the server at ${ApiConfig.baseUrl}. Make sure Laravel is running and your phone is on the same Wi-Fi network.',
      );
    } on TimeoutException {
      throw const AuthException(
        'The request timed out. Please check your server connection and try again.',
      );
    } on FormatException {
      throw const AuthException('The server returned unreadable data.');
    }
  }

  static Future<AuthSession> updateProfile({
    String? name,
    String? email,
    required String gender,
    String? phoneNumber,
    String? photo,
  }) async {
    final session = await AuthStorage.getSession();

    if (session == null) {
      throw const AuthException(
        'Your session was not found. Please sign in again.',
      );
    }

    final body = <String, String>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      'gender': gender,
      if (phoneNumber != null) 'no_telp': phoneNumber,
      if (photo != null) 'foto': photo,
    };

    try {
      final response = await http
          .put(
            _uri('/profile'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${session.token}',
            },
            body: body,
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildAuthException(response.body);
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      final updatedUser =
          AuthUser.fromJson(decoded['data'] as Map<String, dynamic>);

      final updatedSession = AuthSession(
        token: session.token,
        user: updatedUser,
      );

      await AuthStorage.saveSession(updatedSession);
      await NotificationService.maybeLogProfileUpdate(updatedSession);

      return updatedSession;
    } on SocketException {
      throw AuthException(
        'Cannot reach the server at ${ApiConfig.baseUrl}. Make sure Laravel is running and your phone is on the same Wi-Fi network.',
      );
    } on TimeoutException {
      throw const AuthException(
        'The request timed out. Please check your server connection and try again.',
      );
    } on FormatException {
      throw const AuthException('The server returned unreadable data.');
    }
  }

  static Future<bool> shouldShowPermissionFlow(AuthSession session) async {
    return !(await AuthStorage.isPermissionFlowCompleted(
      session.user.id.toString(),
    ));
  }

  static Future<void> completePermissionFlow(AuthSession session) async {
    await AuthStorage.markPermissionFlowCompleted(session.user.id.toString());
  }

  static Future<http.Response> _post(
    String path, {
    required Map<String, String> body,
  }) async {
    try {
      return await http
          .post(
            _uri(path),
            headers: {'Accept': 'application/json'},
            body: body,
          )
          .timeout(_requestTimeout);
    } on SocketException {
      throw AuthException(
        'Cannot reach the server at ${ApiConfig.baseUrl}. Make sure Laravel is running and your phone is on the same Wi-Fi network.',
      );
    } on HttpException {
      throw const AuthException('The server returned an invalid response.');
    } on FormatException {
      throw const AuthException('The server returned unreadable data.');
    } on TimeoutException {
      throw const AuthException(
        'The request timed out. Please check your server connection and try again.',
      );
    }
  }

  static AuthSession _parseAuthResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildAuthException(response.body);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>;

    return AuthSession(
      token: data['token'] as String,
      user: AuthUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  static AuthException _buildAuthException(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final fieldErrors = <String, String>{};

      if (decoded['errors'] is Map<String, dynamic>) {
        final errors = decoded['errors'] as Map<String, dynamic>;

        if (errors.isNotEmpty) {
          for (final entry in errors.entries) {
            final value = entry.value;

            if (value is List && value.isNotEmpty) {
              fieldErrors[entry.key] = value.first.toString();
            }
          }

          if (fieldErrors.isNotEmpty) {
            final normalizedFieldErrors = _normalizeFieldErrors(fieldErrors);
            return AuthException(
              normalizedFieldErrors.values.first,
              fieldErrors: normalizedFieldErrors,
            );
          }
        }
      }

      if (decoded['message'] is String &&
          (decoded['message'] as String).isNotEmpty) {
        return AuthException(_normalizeMessage(decoded['message'] as String));
      }
    } catch (_) {
      // Use the default fallback below.
    }

    return const AuthException('Something went wrong. Please try again.');
  }

  static Map<String, String> _normalizeFieldErrors(Map<String, String> fieldErrors) {
    return fieldErrors.map((key, value) {
      if (key == 'email' && value.toLowerCase().contains('taken')) {
        return MapEntry(key, 'Email is already registered. Please log in instead.');
      }
      if (key == 'password' &&
          value.toLowerCase().contains('confirmation')) {
        return MapEntry(key, 'Password confirmation does not match.');
      }
      return MapEntry(key, _normalizeMessage(value));
    });
  }

  static String _normalizeMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('email belum terdaftar')) {
      return 'This email is not registered yet. Please create an account first.';
    }
    if (lower.contains('password yang kamu masukkan salah')) {
      return 'Incorrect password. Please try again.';
    }
    if (lower.contains('email atau password salah')) {
      return 'Email or password is incorrect.';
    }
    if (lower.contains('unique') || lower.contains('already been taken')) {
      return 'This email is already registered. Please log in instead.';
    }
    if (lower.contains('password') && lower.contains('confirmation')) {
      return 'Password confirmation does not match.';
    }

    return message;
  }
}

class AuthException implements Exception {
  const AuthException(this.message, {this.fieldErrors = const {}});

  final String message;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}

class GoogleAuthResult {
  const GoogleAuthResult._({
    this.session,
    this.profile,
    this.message,
    required this.isRegistered,
  });

  const GoogleAuthResult.registered({
    required AuthSession session,
  }) : this._(
          session: session,
          isRegistered: true,
        );

  const GoogleAuthResult.unregistered({
    required GoogleRegistrationProfile profile,
    String? message,
  }) : this._(
          profile: profile,
          message: message,
          isRegistered: false,
        );

  final AuthSession? session;
  final GoogleRegistrationProfile? profile;
  final String? message;
  final bool isRegistered;
}

class GoogleRegistrationProfile {
  const GoogleRegistrationProfile({
    required this.name,
    required this.email,
    this.photoUrl,
    this.googleUid,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final String? googleUid;
}
