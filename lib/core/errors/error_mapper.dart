import 'package:dio/dio.dart';

import 'bank_error.dart';

/// Converts raw Dio errors and HTTP responses into [BankError].
/// Repositories call this so that no DioException ever reaches the UI.
class ErrorMapper {
  const ErrorMapper();

  /// Maps a [DioException] to a [BankError].
  BankError mapDioException(DioException e) {
    // Extract traceId from response body if available
    final String? traceId = _extractTraceId(e.response?.data);
    final String? serverMessage = _extractMessage(e.response?.data);

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => NetworkError(traceId: traceId),
      DioExceptionType.badResponse => _mapStatusCode(
        e.response?.statusCode,
        serverMessage,
        traceId,
        e.response?.data,
      ),
      DioExceptionType.cancel => const NetworkError(
        message: 'Request was cancelled.',
      ),
      _ => UnknownError(traceId: traceId),
    };
  }

  /// Maps an HTTP status code to the appropriate [BankError].
  BankError _mapStatusCode(
    int? statusCode,
    String? serverMessage,
    String? traceId,
    dynamic responseData,
  ) {
    return switch (statusCode) {
      401 => UnauthorizedError(traceId: traceId),
      403 => ForbiddenError(
        message:
            serverMessage ??
            'You do not have permission to perform this action.',
        traceId: traceId,
      ),
      404 => NotFoundError(
        message: serverMessage ?? 'The requested resource was not found.',
        traceId: traceId,
      ),
      409 => ConflictError(
        message: serverMessage ?? 'This action has already been performed.',
        traceId: traceId,
      ),
      422 => ValidationError(
        message: serverMessage ?? 'The request could not be processed.',
        traceId: traceId,
        details: _extractDetails(responseData),
      ),
      final code when code != null && code >= 500 => ServerError(
        message:
            serverMessage ??
            'Something went wrong on our end. Please try again later.',
        traceId: traceId,
      ),
      _ => UnknownError(
        message: serverMessage ?? 'An unexpected error occurred.',
        traceId: traceId,
      ),
    };
  }

  String? _extractTraceId(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return error['traceId'] as String?;
      }
    }
    return null;
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return error['message'] as String?;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractDetails(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return error['details'] as Map<String, dynamic>?;
      }
    }
    return null;
  }
}
