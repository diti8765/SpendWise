import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/bank_error.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/secure_session_store.dart';
import '../domain/auth_models.dart';

/// Provides the [AuthRepository] singleton.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(apiClientProvider),
    sessionStore: ref.watch(secureSessionStoreProvider),
  );
});

/// Handles authentication operations:
/// - Login with customer ID and PIN
/// - Session restoration from secure storage
/// - Logout and token cleanup
///
/// In development, uses mock responses so the app runs without a backend.
class AuthRepository {
  final Dio _dio;
  final SecureSessionStore _sessionStore;
  final ErrorMapper _errorMapper = const ErrorMapper();

  /// Mock mode for local development without a backend.
  static const bool _useMock = true;

  AuthRepository({required Dio dio, required SecureSessionStore sessionStore})
    : _dio = dio, // ignore: prefer_initializing_formals
      _sessionStore = sessionStore; // ignore: prefer_initializing_formals

  /// Attempts login with the given credentials.
  /// Returns a [UserSession] on success.
  /// Throws [BankError] on failure.
  Future<UserSession> login(LoginRequest request) async {
    if (_useMock) {
      return _mockLogin(request);
    }

    try {
      final response = await _dio.post('/auth/login', data: request.toJson());
      final session = UserSession.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _sessionStore.saveToken(session.token);
      await _sessionStore.saveUserId(session.userId);
      return session;
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  /// Attempts to restore a session from secure storage.
  /// Returns null if no valid session exists.
  Future<UserSession?> restoreSession() async {
    final token = await _sessionStore.getToken();
    final userId = await _sessionStore.getUserId();
    final userName = await _sessionStore.getUserName();
    final customerId = await _sessionStore.getCustomerId();

    if (token == null || userId == null) return null;

    if (_useMock) {
      return UserSession(
        userId: userId,
        customerId: customerId ?? 'CUST001',
        name: userName ?? 'Ananya Sharma',
        token: token,
      );
    }

    // In production, validate the token with the server.
    try {
      final response = await _dio.get('/auth/me');
      return UserSession.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      // Token invalid/expired — clear and return null.
      await _sessionStore.clearSession();
      return null;
    }
  }

  /// Logs out by clearing the session.
  Future<void> logout() async {
    await _sessionStore.clearSession();
  }

  // --- Mock implementation for development ---

  Future<UserSession> _mockLogin(LoginRequest request) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Simulate validation
    if (request.customerId.isEmpty || request.pin.isEmpty) {
      throw const ValidationError(message: 'Customer ID and PIN are required.');
    }

    // Simulate wrong credentials
    if (request.pin == '0000') {
      throw const UnauthorizedError(message: 'Invalid customer ID or PIN.');
    }

    final inputName = request.customerId.trim();
    final String formattedName;
    if (inputName.toLowerCase() == 'ananya') {
      formattedName = 'Ananya Sharma';
    } else if (inputName.toLowerCase() == 'deepak') {
      formattedName = 'Deepak Verma';
    } else if (inputName.toLowerCase() == 'sara') {
      formattedName = 'Sara Khan';
    } else if (inputName.isNotEmpty) {
      formattedName = inputName
          .split(' ')
          .map((word) {
            if (word.isEmpty) return word;
            return word[0].toUpperCase() + word.substring(1);
          })
          .join(' ');
    } else {
      formattedName = 'User';
    }

    final session = UserSession(
      userId: 'user_${request.customerId}',
      customerId: request.customerId,
      name: formattedName,
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    await _sessionStore.saveToken(session.token);
    await _sessionStore.saveUserId(session.userId);
    await _sessionStore.saveUserName(session.name);
    await _sessionStore.saveCustomerId(session.customerId);
    return session;
  }
}
