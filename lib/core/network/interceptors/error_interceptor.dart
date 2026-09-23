import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/state/auth_provider.dart';

/// Intercepts 401 responses to trigger session clearance.
/// The actual error mapping (DioException → BankError) happens in repositories,
/// not here. This interceptor handles the side-effect of session expiry.
class ErrorInterceptor extends Interceptor {
  final Ref _ref;

  ErrorInterceptor(this._ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear session when a 401 occurs; auth notifier and router react automatically.
      _ref.read(authStateProvider.notifier).logout();
    }
    // Always pass the error along for the repository to handle.
    handler.next(err);
  }
}
