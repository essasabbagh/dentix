import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/constants/keys.dart';
import 'package:template/core/data/secure_storage_service.dart';
import 'package:template/features/auth/providers/auth_provider.dart';
import 'package:template/initialize_app.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  /// Prevents executing logout multiple times
  /// (protects against infinite 401 logout loops)
  static bool _isLoggingOut = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read access token from secure storage
    final token = await locator<SecureStorageService>().read(tokenKey);

    // Attach Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continue the request
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    /*
     * Handle Unauthorized (401) responses safely
     *
     * Conditions:
     * 1. Status code is 401
     * 2. Logout process is NOT already running
     * 3. The request is NOT the logout endpoint itself
     *
     * This prevents infinite logout loops when /logout also returns 401
     */
    if (statusCode == 401 && !_isLoggingOut && !path.contains('/logout')) {
      _isLoggingOut = true;

      try {
        // Update authentication state (Riverpod)
        ProviderScope.containerOf(
          rootNavigatorKey.currentContext!,
        ).read(authNotifierProvider.notifier).logout();
      } finally {
        // Always reset the flag, even if something fails
        _isLoggingOut = false;
      }
    }

    // IMPORTANT:
    // Always forward the error so Dio can complete the Future
    // and allow try/catch blocks to work correctly
    return handler.next(err);
  }
}
