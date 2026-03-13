import 'error_handler.dart';

/// Extension methods for easier error handling
extension FutureErrorHandling<T> on Future<T> {
  /// Catch errors and convert them to AppException
  Future<T> catchAppError() {
    return catchError((error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
    });
  }
}
