import 'dart:convert';

import 'package:frontend/core/auth/models/auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
  });

  final String token;
  final AuthUser user;

  String toStorageValue() {
    return jsonEncode({
      'token': token,
      'user': user.toJson(),
    });
  }

  factory AuthSession.fromStorageValue(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    return AuthSession(
      token: decoded['token'] as String,
      user: AuthUser.fromJson(decoded['user'] as Map<String, dynamic>),
    );
  }
}
