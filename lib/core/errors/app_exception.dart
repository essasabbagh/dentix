import 'status_code.dart';

/// Main exception class for the app with enhanced error information
class AppException implements Exception {
  AppException({
    required this.message,
    this.statusCode = StatusCode.unknown,
    this.data,
    this.stackTrace,
  });

  final String message;
  final StatusCode statusCode;
  final dynamic data;
  final StackTrace? stackTrace;

  /// Check if error is retryable (network, timeout, server errors)
  bool get isRetryable => switch (statusCode) {
    StatusCode.noInternet ||
    StatusCode.timeout ||
    StatusCode.serverError ||
    StatusCode.connectionError => true,
    _ => false,
  };

  /// Check if error requires authentication
  bool get requiresAuth => statusCode == StatusCode.unauthorized;

  /// Check if error suggests going back/navigation
  bool get suggestsGoBack => switch (statusCode) {
    StatusCode.forbidden || StatusCode.notFound => true,
    _ => false,
  };

  @override
  String toString() => message;
}
