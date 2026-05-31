import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend/core/auth/services/auth_service.dart';
import 'package:frontend/core/constants/api_config.dart';
import 'package:frontend/features/profile/models/profile_stats_model.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  ProfileService._();

  static const _requestTimeout = Duration(seconds: 15);

  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  static Future<ProfileStatsModel> getProfileStats() async {
    final session = await AuthService.currentSession();

    if (session == null) {
      throw const AuthException(
        'Token tidak ditemukan. Silakan login ulang.',
      );
    }

    try {
      final response = await http
          .get(
            _uri('/profile/stats'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${session.token}',
            },
          )
          .timeout(_requestTimeout);

      debugPrintProfileStats(response);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileStatsModel.fromJson(decoded);
      }

      throw AuthException(
        'Gagal mengambil profile stats. Status: ${response.statusCode}',
      );
    } on SocketException {
      throw const AuthException(
        'Cannot reach the server. Make sure Laravel is running and your phone is on the same Wi-Fi network.',
      );
    } on TimeoutException {
      throw const AuthException(
        'The request timed out. Please check your server connection and try again.',
      );
    } on FormatException {
      throw const AuthException(
        'The server returned unreadable data.',
      );
    }
  }

  static void debugPrintProfileStats(http.Response response) {
    // Boleh dihapus kalau nanti sudah aman.
    print('PROFILE STATS STATUS: ${response.statusCode}');
    print('PROFILE STATS BODY: ${response.body}');
  }
}