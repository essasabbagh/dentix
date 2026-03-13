import 'package:flutter/material.dart';

import '../locale/generated/l10n.dart';

import 'app_exception.dart';
import 'empty_state_widget.dart';
import 'error_handler.dart';

/// Enhanced empty state widget integrated with error handling system
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.exception,
    this.onRetry,
    this.onGoBack,
    this.onLogin,
    this.showDebugInfo = false,
    this.padding,
  });

  /// Factory constructor for handling raw errors
  factory AppErrorWidget.fromError(
    Object? error,
    StackTrace? stackTrace, {
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
    VoidCallback? onLogin,
    bool showDebugInfo = false,
    EdgeInsetsGeometry? padding,
  }) {
    final appException = ErrorHandler.handle(error, stackTrace);
    return AppErrorWidget(
      exception: appException,
      onRetry: onRetry,
      onGoBack: onGoBack,
      onLogin: onLogin,
      showDebugInfo: showDebugInfo,
      padding: padding,
    );
  }
  final AppException exception;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final VoidCallback? onLogin;
  final bool showDebugInfo;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: EmptyStateWidget(
              title: exception.statusCode.title,
              subtitle: exception.message,
              imagePath: exception.statusCode.imagePath,
              actionText: _getActionText(),
              onActionPressed: _getActionCallback(),
              padding: padding ?? const EdgeInsets.all(24.0),
            ),
          ),
          if (showDebugInfo) _buildDebugInfo(context),
        ],
      ),
    );
  }

  /// Determine appropriate action text based on error type
  String? _getActionText() {
    // Authentication required
    if (exception.requiresAuth && onLogin != null) {
      return S.current.login;
    }

    // Retryable errors
    if (exception.isRetryable && onRetry != null) {
      return S.current.tryAgain;
    }

    // Navigation suggestions
    if (exception.suggestsGoBack && onGoBack != null) {
      return S.current.goBack;
    }

    // Fallback retry option
    if (onRetry != null) {
      return S.current.retry;
    }

    return null;
  }

  /// Determine appropriate action callback based on error type
  VoidCallback? _getActionCallback() {
    // Authentication required
    if (exception.requiresAuth && onLogin != null) {
      return onLogin;
    }

    // Retryable errors
    if (exception.isRetryable && onRetry != null) {
      return onRetry;
    }

    // Navigation suggestions
    if (exception.suggestsGoBack && onGoBack != null) {
      return onGoBack;
    }

    // Fallback retry option
    return onRetry;
  }

  /// Build debug information panel for development
  Widget _buildDebugInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, size: 16, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(
                'Debug Info',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDebugRow('Status Code', exception.statusCode.name),
          _buildDebugRow('HTTP Code', exception.statusCode.code.toString()),
          _buildDebugRow('Message', exception.message),
          if (exception.data != null)
            _buildDebugRow('Data', exception.data.toString()),
          if (exception.stackTrace != null)
            _buildDebugRow(
              'Stack',
              exception.stackTrace.toString().split('\n').take(3).join('\n'),
            ),
        ],
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
