import 'package:local_auth/local_auth.dart';

class FingerprintService {
  FingerprintService._();

  static final _auth = LocalAuthentication();

  /// Cek apakah HP support biometrik
  static Future<bool> isAvailable() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Minta user scan sidik jari
  /// Return true kalau berhasil
  static Future<bool> authenticate({
  String reason = 'Scan your fingerprint to login',
}) async {
  try {
    final result = await _auth.authenticate(
      localizedReason: reason,
    );
    return result;
  } catch (e) {
    print('Fingerprint error: $e'); // ganti jadi print biasa
    return false;
  }
}
}
