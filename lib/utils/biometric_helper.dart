// biometric_helper.dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricHelper {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final types = await _localAuth.getAvailableBiometrics();
      return canCheck && isSupported && types.isNotEmpty;
    } catch (e) {
      print('Biometric availability error: $e');
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = true, // Enforce biometric-only (no passcode fallback)
  }) async {
    try {
      final available = await isAvailable();
      if (!available) return false;
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Biometric auth error: $e');
      return false;
    } catch (e) {
      print('Biometric auth error: $e');
      return false;
    }
  }

  static String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometric';
  }
}
