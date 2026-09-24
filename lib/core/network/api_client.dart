import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Provides the configured [Dio] instance used by all repositories.
/// Repositories inject this via Riverpod; widgets never touch it.
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Order matters: auth adds the token, error intercepts failures.
  dio.interceptors.addAll([
    AuthInterceptor(ref),
    ErrorInterceptor(ref),
    if (const bool.fromEnvironment('DEBUG', defaultValue: true))
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        // SECURITY: Never log Authorization headers (they contain tokens).
        requestHeader: false,
      ),
  ]);

  return dio;
});
