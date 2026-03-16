import 'package:flutter/material.dart';

import 'package:dentix/core/themes/app_colors.dart';

class PrimaryOutlinedButton extends StatelessWidget {
  const PrimaryOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 20,
    this.padding = const EdgeInsets.all(10),
    this.borderColor = AppColors.primaryColor,
    this.textColor = AppColors.primaryColor,
    this.fontWeight = FontWeight.bold,
  });
  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color textColor;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          const BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: padding,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
