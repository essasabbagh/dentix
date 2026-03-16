import 'package:flutter/material.dart';

import 'package:dentix/core/locale/generated/l10n.dart';
import 'package:dentix/core/utils/app_log.dart';

import '../constants/keys.dart';

/// Enhanced SnackBar utility class to display modern, animated snackbars
/// with icons, gradient backgrounds, and smooth animations
class AppSnackBar {
  // Duration constants
  static const Duration _displayDuration = Duration(seconds: 4);
  static const Duration _animationDuration = Duration(milliseconds: 500);

  // Animation controllers
  static AnimationController? _animationController;

  /// Shows a success snackbar with the given message
  static void success(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) {
    AppLog.success(message);
    _show(
      message: message,
      icon: Icons.check_circle_outline,
      backgroundIcon: Icons.check_circle,
      title: S.current.success,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF388E3C), // dark green
          Color(0xFF4CAF50), // medium green
          Color(0xFF66BB6A), // light green
        ],
      ),
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: onDismiss,
    );
  }

  /// Shows an error snackbar with the given message
  static void error(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) {
    AppLog.error(message);
    _show(
      message: message,
      icon: Icons.error_outline,
      backgroundIcon: Icons.error,
      title: S.current.error,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFC62828), // dark red
          Color(0xFFD32F2F), // medium red
          Color(0xFFE53935), // light red
        ],
      ),
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: onDismiss,
    );
  }

  /// Shows a warning snackbar with the given message
  static void warning(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) {
    AppLog.warning(message);
    _show(
      message: message,
      icon: Icons.warning_amber_outlined,
      backgroundIcon: Icons.warning_amber_rounded,
      title: S.current.warning,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF57C00), // dark amber
          Color(0xFFFF9800), // medium amber
          Color(0xFFFFA726), // light amber
        ],
      ),
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: onDismiss,
    );
  }

  /// Shows an info snackbar with the given message
  static void info(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) {
    AppLog.info(message);
    _show(
      message: message,
      icon: Icons.info_outline,
      backgroundIcon: Icons.info,
      title: S.current.info,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1565C0), // dark blue
          Color(0xFF1976D2), // medium blue
          Color(0xFF1E88E5), // light blue
        ],
      ),
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: onDismiss,
    );
  }

  /// Shows a snackbar with the given parameters
  static void _show({
    required String message,
    required IconData icon,
    required IconData backgroundIcon,
    required String title,
    required Gradient gradient,
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) {
    // Clear any existing SnackBars
    scaffoldKey.currentState?.clearSnackBars();

    // Calculate colors
    final iconColor = Colors.white.withValues(alpha: 0.9);
    const textColor = Colors.white;

    // Create a custom snackbar with slide animation
    final snackBar = SnackBar(
      content: _buildAnimatedContent(
        message: message,
        icon: icon,
        backgroundIcon: backgroundIcon,
        title: title,
        gradient: gradient,
        iconColor: iconColor,
        textColor: textColor,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.fixed, // Full width by default
      duration: _displayDuration,
      dismissDirection: DismissDirection.down,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );

    // Show the SnackBar
    scaffoldKey.currentState?.showSnackBar(snackBar).closed.then((reason) {
      _animationController?.dispose();
      _animationController = null;
      if (onDismiss != null) onDismiss();
    });
  }

  /// Builds the animated content widget for the snackbar
  static Widget _buildAnimatedContent({
    required String message,
    required IconData icon,
    required IconData backgroundIcon,
    required String title,
    required Gradient gradient,
    required Color iconColor,
    required Color textColor,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        _animationController ??= AnimationController(
          vsync: ScaffoldMessenger.of(context),
          duration: _animationDuration,
        );

        // Animations
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 1.0), // Start from bottom
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController!,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        );

        // Start the animation
        _animationController!.forward();

        // Return animated container
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: _buildGradientContent(
              message: message,
              icon: icon,
              backgroundIcon: backgroundIcon,
              title: title,
              gradient: gradient,
              iconColor: iconColor,
              textColor: textColor,
              context: context,
              actionLabel: actionLabel,
              onAction: onAction,
            ),
          ),
        );
      },
    );
  }

  /// Builds the gradient content with background icon
  static Widget _buildGradientContent({
    required String message,
    required IconData icon,
    required IconData backgroundIcon,
    required String title,
    required Gradient gradient,
    required Color iconColor,
    required Color textColor,
    required BuildContext context,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    // Check for RTL context
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Create RTL-aware gradient
    final rtlAwareGradient = _createRTLAwareGradient(gradient, isRTL);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: rtlAwareGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background overlay icon - properly positioned for RTL/LTR
          Positioned(
            right: isRTL ? null : -10,
            left: isRTL ? -10 : null,
            top: -16,
            child: Icon(
              backgroundIcon,
              size: 80,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          // Content with proper directionality
          Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Leading icon (always on the start side)
                  Icon(icon, color: iconColor, size: 24),
                  const SizedBox(width: 16),

                  // Expanded content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(color: textColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),

                  // Action button (always on the end side)
                  if (actionLabel != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // Add animation for dismissal
                        _animationController?.reverse().then((_) {
                          scaffoldKey.currentState?.hideCurrentSnackBar();
                          if (onAction != null) onAction();
                        });
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: Colors.white.withAlpha(225),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          color: gradient.colors.last,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates an RTL-aware gradient by adjusting the begin and end alignments
  static Gradient _createRTLAwareGradient(
    Gradient originalGradient,
    bool isRTL,
  ) {
    if (originalGradient is LinearGradient) {
      // For RTL, flip the horizontal component of the alignment
      Alignment adjustedBegin = originalGradient.begin as Alignment;
      Alignment adjustedEnd = originalGradient.end as Alignment;

      if (isRTL) {
        adjustedBegin = Alignment(
          -adjustedBegin.x, // Flip horizontal
          adjustedBegin.y, // Keep vertical
        );
        adjustedEnd = Alignment(
          -adjustedEnd.x, // Flip horizontal
          adjustedEnd.y, // Keep vertical
        );
      }

      return LinearGradient(
        begin: adjustedBegin,
        end: adjustedEnd,
        colors: originalGradient.colors,
        stops: originalGradient.stops,
        tileMode: originalGradient.tileMode,
        transform: originalGradient.transform,
      );
    }

    // For other gradient types, return as-is
    return originalGradient;
  }
}

// Example usage:
void exampleUsage() {
  // Success example
  AppSnackBar.success(
    'تم تحديث الملف الشخصي بنجاح!', // Arabic text for RTL testing
    actionLabel: 'عرض',
    onAction: () {
      // Navigate to profile
    },
  );

  // Error example
  AppSnackBar.error(
    'Failed to connect to server',
    actionLabel: 'Retry',
    onAction: () {
      // Retry connection
    },
  );

  // Warning example with long text
  AppSnackBar.warning(
    'This is a very long warning message that should be properly truncated with'
    ' ellipsis when it exceeds the maximum number of lines allowed'
    ' in the snackbar',
    actionLabel: 'Dismiss',
    onAction: () {
      // Handle dismiss
    },
  );

  // Info example
  AppSnackBar.info(
    'New features are available',
    actionLabel: 'Learn More',
    onAction: () {
      // Show features
    },
  );
}

/* Setup instructions for your app
 * 
 * In your MaterialApp:
 * MaterialApp(
 *   scaffoldMessengerKey: scaffoldKey,
 *   // other properties
 * )
 * 
 * For proper RTL support, also ensure:
 * MaterialApp(
 *   scaffoldMessengerKey: scaffoldKey,
 *   localizationsDelegates: [
 *     GlobalMaterialLocalizations.delegate,
 *     GlobalWidgetsLocalizations.delegate,
 *     GlobalCupertinoLocalizations.delegate,
 *   ],
 *   supportedLocales: [
 *     Locale('en', ''), // English
 *     Locale('ar', ''), // Arabic
 *     // Add other locales as needed
 *   ],
 *   // other properties
 * )
 */
