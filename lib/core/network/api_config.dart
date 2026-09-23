/// API configuration resolved from --dart-define environment variables.
/// Usage: flutter run --dart-define=API_BASE_URL=http://localhost:3000
class ApiConfig {
  /// Base URL for the API. Defaults to localhost for development.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Connection timeout in milliseconds.
  static const int connectTimeoutMs = 10000;

  /// Receive timeout in milliseconds.
  static const int receiveTimeoutMs = 15000;

  /// Default page size for cursor pagination.
  static const int defaultPageSize = 20;
}
