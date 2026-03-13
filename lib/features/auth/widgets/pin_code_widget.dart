import 'package:flutter/material.dart';

import 'package:pinput/pinput.dart';

import 'package:template/configs/app_configs.dart';
import 'package:template/core/extensions/context_ext.dart';
import 'package:template/core/utils/validators.dart';
import 'package:template/core/themes/app_colors.dart';

class PinCodeWidget extends StatelessWidget {
  const PinCodeWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onCompleted,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String val)? onCompleted;
  final void Function(String val)? onChanged;

  @override
  Widget build(BuildContext context) {
    double height = context.isPhone ? 50 : 58;

    BoxDecoration buildShadowBox({
      required bool isFocused,
      bool isError = false,
    }) {
      final fillColor = context.isDark ? AppColors.gray900 : AppColors.gray100;

      final borderColor = isError
          ? AppColors.error600
          : (isFocused
                ? AppColors.primaryColor
                : (context.isDark ? AppColors.gray700 : AppColors.gray300));

      return BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: borderColor, width: 1.5),
      );
    }

    final defaultPinTheme = PinTheme(
      width: height,
      height: height,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: buildShadowBox(isFocused: false),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: buildShadowBox(isFocused: true),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: buildShadowBox(isFocused: true, isError: true),
    );

    return Pinput(
      showCursor: true,
      controller: controller,
      focusNode: focusNode,
      errorPinTheme: errorPinTheme,
      length: AppConfigs.pinDigitLength,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: defaultPinTheme,
      cursor: Container(width: 2, height: 24, color: AppColors.primaryColor),
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      separatorBuilder: (index) {
        return SizedBox(width: context.isPhone ? 10 : 25);
      },
      validator: pinDigitValidator,
      onChanged: onChanged,
      onCompleted: onCompleted,
      errorBuilder: (errorText, pin) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              errorText ?? '',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                color: AppColors.error600,
              ),
            ),
          ],
        );
      },
    );
  }
}
