import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/auth/models/auth_user.dart';
import 'package:frontend/core/auth/services/auth_storage.dart';
import 'package:frontend/core/constants/api_config.dart';
import 'package:http/http.dart' as http;

class AuthService {
  AuthService._();

  static const _requestTimeout = Duration(seconds: 15);

  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

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
    return session;
  }

  static Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _post(
      '/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final session = _parseAuthResponse(response);
    await AuthStorage.saveSession(session);
    return session;
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
      final refreshedSession = AuthSession(token: localSession.token, user: user);
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
        // Local logout still proceeds even if the backend request fails.
      }
    }

    await AuthStorage.clearSession();
  }

  static Future<AuthSession> updateProfile({
    required String gender,
    required String phoneNumber,
    String? photo,
  }) async {
    final session = await AuthStorage.getSession();
    if (session == null) {
      throw const AuthException(
        'Your session was not found. Please sign in again.',
      );
    }

    final response = await http
        .put(
          _uri('/profile'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${session.token}',
          },
          body: {
            'gender': gender,
            'no_telp': phoneNumber,
            if (photo != null) 'foto': photo,
          },
        )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildAuthException(response.body);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final updatedUser = AuthUser.fromJson(decoded['data'] as Map<String, dynamic>);
    final updatedSession = AuthSession(token: session.token, user: updatedUser);
    await AuthStorage.saveSession(updatedSession);
    return updatedSession;
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
      throw const AuthException(
        'Cannot reach the server. Make sure Laravel is running and your phone is on the same Wi-Fi network.',
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
            return AuthException(
              fieldErrors.values.first,
              fieldErrors: fieldErrors,
            );
          }
        }
      }

      if (decoded['message'] is String &&
          (decoded['message'] as String).isNotEmpty) {
        return AuthException(decoded['message'] as String);
      }
    } catch (_) {
      // Use the default fallback below.
    }

    return const AuthException('Something went wrong. Please try again.');
  }
}

class AuthException implements Exception {
  const AuthException(this.message, {this.fieldErrors = const {}});

  final String message;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}
