import 'package:flutter/material.dart';

import 'package:dentix/core/themes/app_colors.dart';

import '../loading/loading_widget.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.isLoading,
    required this.text,
    required this.onPressed,
    this.style,
    this.backgroundColor = AppColors.primaryColor,
    this.textStyle,
  });

  final VoidCallback onPressed;
  final ButtonStyle? style;
  final String text;
  final bool isLoading;
  final Color backgroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isLoading,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            style ??
            ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              minimumSize: const Size(double.infinity, 50),
              elevation: 4,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                // side: const BorderSide(color: Colors.red),
              ),
            ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: LoadingWidget(color: AppColors.floralWhite),
              )
            : Text(
                text,
                style:
                    textStyle ??
                    const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
      ),
    );
  }
}
