import 'dart:io';

import 'app_exception.dart';
import 'status_code.dart';

/// Enhanced error handler class with comprehensive error mapping
class ErrorHandler {
  /// Main method to handle any type of error and convert to AppException
  static AppException handle(dynamic error, [StackTrace? stackTrace]) {
    // Handle network connectivity errors
    if (error is SocketException) {
      return AppException(
        message: StatusCode.noInternet.message,
        statusCode: StatusCode.noInternet,
        stackTrace: stackTrace,
      );
    }

    // Handle already processed AppExceptions
    if (error is AppException) {
      return error;
    }

    // Handle format/parsing errors
    if (error is FormatException) {
      return AppException(
        message: StatusCode.formatError.message,
        statusCode: StatusCode.formatError,
        data: error.toString(),
        stackTrace: stackTrace,
      );
    }

    // Handle timeout errors from other sources
    if (error.toString().toLowerCase().contains('timeout')) {
      return AppException(
        message: StatusCode.timeout.message,
        statusCode: StatusCode.timeout,
        data: error.toString(),
        stackTrace: stackTrace,
      );
    }

    // Default unknown error handling
    return AppException(
      message: StatusCode.unknown.message,
      statusCode: StatusCode.unknown,
      data: error.toString(),
      stackTrace: stackTrace,
    );
  }

  /// Quick method to handle Future errors in FutureBuilder
  static AppException handleFutureError(Object error, StackTrace? stackTrace) {
    return handle(error, stackTrace);
  }

  /// Quick method to handle Stream errors in StreamBuilder
  static AppException handleStreamError(Object error, StackTrace? stackTrace) {
    return handle(error, stackTrace);
  }
}
