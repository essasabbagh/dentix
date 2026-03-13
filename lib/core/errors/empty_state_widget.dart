import 'package:flutter/material.dart';

/// Basic empty state widget (assuming this exists from previous artifact)
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.imagePath,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.imageColor,
    this.imageSize = 120,
    this.titleStyle,
    this.subtitleStyle,
    this.padding = const EdgeInsets.all(24.0),
    this.mainAxisAlignment = MainAxisAlignment.center,
  });
  final String? imagePath;
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? imageColor;
  final double? imageSize;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: padding!,
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            if (imagePath != null || icon != null) ...[
              _buildImageOrIcon(theme),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style:
                  titleStyle ??
                  theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style:
                    subtitleStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageOrIcon(ThemeData theme) {
    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        width: imageSize,
        height: imageSize,
        color: imageColor,
        fit: BoxFit.contain,
      );
    } else if (icon != null) {
      return Icon(
        icon!,
        size: imageSize,
        color: imageColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.4),
      );
    }
    return const SizedBox.shrink();
  }
}
