import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provides the [SecureSessionStore] singleton.
final secureSessionStoreProvider = Provider<SecureSessionStore>((ref) {
  return const SecureSessionStore();
});

/// Wraps [FlutterSecureStorage] to manage authentication tokens.
/// Tokens are stored in the platform keychain/keystore.
///
/// SECURITY: This class never logs token values.
class SecureSessionStore {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  const SecureSessionStore();

  FlutterSecureStorage get _storage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Saves the authentication token securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the stored authentication token, or null if not present.
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  /// Saves the user ID for session restoration.
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Retrieves the stored user ID.
  Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  /// Clears all session data (used on logout).
  Future<void> clearSession() async {
    await _storage.deleteAll();
  }

  /// Checks whether a session token exists.
  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
