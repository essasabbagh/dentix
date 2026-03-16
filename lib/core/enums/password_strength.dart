import 'package:flutter/material.dart';

import 'package:dentix/core/locale/generated/l10n.dart';

enum PasswordStrength { weak, medium, strong, veryStrong }

extension PasswordStrengthExtension on PasswordStrength {
  Color color(BuildContext context) {
    switch (this) {
      case PasswordStrength.weak:
        return Colors.redAccent;
      case PasswordStrength.medium:
        return Colors.orangeAccent;
      case PasswordStrength.strong:
        return Colors.amberAccent;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }

  String label(BuildContext context) {
    final locale = S.of(context);

    switch (this) {
      case PasswordStrength.weak:
        return locale.YourPasswordIsWeak;
      case PasswordStrength.medium:
        return locale.YourPasswordIsMedium;
      case PasswordStrength.strong:
        return locale.YourPasswordIsStrong;
      case PasswordStrength.veryStrong:
        return locale.YourPasswordIsVeryStrong;
    }
  }
}
