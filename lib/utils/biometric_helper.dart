import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricHelper {
  static final LocalAuthentication _localAuth = LocalAuthentication();

// biometric_helper.dart
  static Future<bool> isAvailable() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      // Device must support biometrics, be able to check them, AND have at least one type available
      return canCheck && isDeviceSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Biometric availability check failed: $e');
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
    bool biometricOnly = false,
  }) async {
    try {
      final bool isAvailable = await BiometricHelper.isAvailable();
      if (!isAvailable) {
        print('Biometrics not available on device');
        return false;
      }

      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );

      print('Authentication result: $isAuthenticated');
      return isAuthenticated;
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
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
    } else {
      return 'Biometric';
    }
  }
}
