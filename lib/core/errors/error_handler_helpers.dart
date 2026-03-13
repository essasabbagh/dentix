import 'package:flutter/material.dart';

import 'app_error_widget.dart';
import 'error_handler.dart';

/// Helper methods for common error handling patterns
class ErrorHandlerHelpers {
  /// Handle async operations with automatic error conversion
  static Future<T> handleAsync<T>(Future<T> future) async {
    try {
      return await future;
    } catch (error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
    }
  }

  /// Create error widget for common HTTP operations
  static Widget buildApiErrorWidget(
    Object error,
    StackTrace? stackTrace, {
    required VoidCallback onRetry,
    VoidCallback? onLogin,
  }) {
    return AppErrorWidget.fromError(
      error,
      stackTrace,
      onRetry: onRetry,
      onLogin: onLogin,
    );
  }
}
