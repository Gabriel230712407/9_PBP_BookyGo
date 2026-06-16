// ini dah Railway
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String productionBaseUrl =
      'https://9pbpbookygo-production.up.railway.app/api';

  static const _configuredBaseUrl = String.fromEnvironment(
    'BOOKYGO_API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    // Kalau sudah build APK release, otomatis pakai Railway
    if (kReleaseMode) {
      return productionBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://192.168.0.147:8000/api';
      default:
        return 'http://127.0.0.1:8000/api';
    }
  }
}