import 'package:flutter/material.dart';

import 'package:template/core/enums/password_strength.dart';
import 'package:template/core/extensions/context_ext.dart';
import 'package:template/core/utils/validators.dart';
import 'package:template/core/themes/app_colors.dart';

class PasswordStrengthChecker extends StatelessWidget {
  const PasswordStrengthChecker({
    super.key,
    required this.password,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          'password Requirement 8',
          // S.of(context).passwordRequirement(AppConfigs.passwordMinLength),
          style: context.textTheme.bodyMedium,
        ),
      );
    }

    final strength = getPasswordStrength(password);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            tween: Tween<double>(
              begin: 0,
              end: (strength.index + 1) / 4,
            ),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.gray300,
                color: strength.color(context),
                minHeight: 6,
                borderRadius: BorderRadius.circular(16),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            strength.label(context),
            style: TextStyle(
              color: strength.color(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
