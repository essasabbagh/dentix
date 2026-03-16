import 'package:flutter/material.dart';

import 'package:dentix/core/themes/app_colors.dart';
import 'package:dentix/core/themes/app_gradients.dart';

import '../loading/loading_widget.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.gradient,
    this.textStyle,
  });

  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final LinearGradient? gradient;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient ?? AppGradient.linearGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isLoading ? null : onPressed,
          child: Container(
            alignment: Alignment.center,
            height: 50,
            width: double.infinity,
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
        ),
      ),
    );
  }
}
