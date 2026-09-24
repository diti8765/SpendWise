import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Provides the [BiometricService] singleton.
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Wraps [LocalAuthentication] for biometric and device-PIN unlock.
/// Used by the app lock feature (B2 baseline requirement).
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks whether biometric authentication is available on this device.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Attempts biometric authentication.
  /// Returns true if the user authenticated successfully.
  /// Falls back to device PIN if biometrics are not enrolled.
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          // Allow device PIN as fallback
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
