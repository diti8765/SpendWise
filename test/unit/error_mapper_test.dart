import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/errors/bank_error.dart';
import 'package:spendwise/core/errors/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    const mapper = ErrorMapper();

    test('maps connection timeout to NetworkError', () {
      final dioError = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final error = mapper.mapDioException(dioError);
      expect(error, isA<NetworkError>());
    });

    test('maps 401 to UnauthorizedError', () {
      final dioError = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      final error = mapper.mapDioException(dioError);
      expect(error, isA<UnauthorizedError>());
    });

    test('maps 404 to NotFoundError with server message', () {
      final dioError = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 404,
          data: {
            'error': {
              'message': 'Transaction not found',
              'traceId': 'trace_123',
            },
          },
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      final error = mapper.mapDioException(dioError);
      expect(error, isA<NotFoundError>());
      expect(error.message, 'Transaction not found');
      expect(error.traceId, 'trace_123');
    });

    test('maps 422 to ValidationError with details', () {
      final dioError = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 422,
          data: {
            'error': {
              'message': 'Validation failed',
              'details': {'amount': 'Must be greater than 0'},
            },
          },
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      final error = mapper.mapDioException(dioError);
      expect(error, isA<ValidationError>());
      expect(
        (error as ValidationError).details?['amount'],
        'Must be greater than 0',
      );
    });

    test('maps 500 to ServerError', () {
      final dioError = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );
      final error = mapper.mapDioException(dioError);
      expect(error, isA<ServerError>());
    });
  });
}
