/// Sealed error type for all API/network errors in SpendWise.
/// Widgets never see DioException or raw HTTP codes — only BankError.
sealed class BankError implements Exception {
  final String message;
  final String? traceId;

  const BankError({required this.message, this.traceId});

  @override
  String toString() => 'BankError: $message';
}

/// No internet or connection timeout.
class NetworkError extends BankError {
  const NetworkError({
    super.message = 'Unable to connect. Please check your internet connection.',
    super.traceId,
  });
}

/// 401 — session expired or invalid token.
class UnauthorizedError extends BankError {
  const UnauthorizedError({
    super.message = 'Your session has expired. Please sign in again.',
    super.traceId,
  });
}

/// 403 — user does not have access.
class ForbiddenError extends BankError {
  const ForbiddenError({
    super.message = 'You do not have permission to perform this action.',
    super.traceId,
  });
}

/// 404 — resource not found.
class NotFoundError extends BankError {
  const NotFoundError({
    super.message = 'The requested resource was not found.',
    super.traceId,
  });
}

/// 422 — validation failed (e.g. invalid amount, missing field).
class ValidationError extends BankError {
  final Map<String, dynamic>? details;
  const ValidationError({
    super.message = 'The request could not be processed.',
    super.traceId,
    this.details,
  });
}

/// 409 — conflict (e.g. duplicate idempotency key).
class ConflictError extends BankError {
  const ConflictError({
    super.message = 'This action has already been performed.',
    super.traceId,
  });
}

/// 5xx — server error.
class ServerError extends BankError {
  const ServerError({
    super.message = 'Something went wrong on our end. Please try again later.',
    super.traceId,
  });
}

/// Catch-all for unexpected errors.
class UnknownError extends BankError {
  const UnknownError({
    super.message = 'An unexpected error occurred.',
    super.traceId,
  });
}
