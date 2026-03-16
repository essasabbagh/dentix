import 'package:dentix/configs/app_configs.dart';
import 'package:dentix/core/constants/constants.dart';
import 'package:dentix/core/enums/password_strength.dart';
import 'package:dentix/core/locale/generated/l10n.dart';

/// Validates a password based on certain criteria.
///
/// This function checks if the given password meets the following requirements:
/// - It is not null or empty.
/// - It is at least 8 characters long.
/// - It contains at least one number.
/// - It contains at least one letter.
/// - It contains at least one capital letter.
/// - It contains at least one number and letter.
///
/// @param val The password to be validated.
/// @return A [String] message indicating the validation result.
/// If the password is valid, it returns `null`.
String? passwordValidator(String? val) {
  if (val == null || val.isEmpty) {
    return S.current.passwordEmpty;
  }

  if (val.length < AppConfigs.passwordMinLength) {
    return S.current.passwordTooShortt(AppConfigs.passwordMinLength);
  }

  if (!AppRegex.numRegEx.hasMatch(val.trim())) {
    return S.current.passwordMissingNumber;
  }

  if (!AppRegex.letterRegEx.hasMatch(val.trim())) {
    return S.current.passwordMissingLetter;
  }

  if (!AppRegex.uppercaseRegEx.hasMatch(val.trim())) {
    return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
  }

  // if (!AppRegex.passwordRegEx.hasMatch(val)) {
  //   return 'يجب أن تحتوي كلمة المرور على رقم واحد وحرف واحد على الأقل';
  // }

  return null; // Return null if validation passes
}

/// Validates password.
String? passwordLoginValidator(String? val) {
  if (val == null || val.isEmpty) {
    return S.current.passwordEmpty;
  }

  return null; // Return null if validation passes
}

String? confirmPasswordValidator(String? password, String? confirmPassword) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return S.current.confirmPasswordEmpty;
  }
  if (confirmPassword != password) {
    return S.current.confirmPasswordNotMatch;
  }
  return null;
}

String? oldPasswordValidator(String? password) {
  if (password == null || password.isEmpty) {
    return S.current.oldPasswordRequired;
  }

  return null;
}

String? emailValidator(String? val) =>
    val != null && AppRegex.emailRegEx.hasMatch(val.trim())
    ? null
    : S.current.invalidEmail;

String? userNameValidator(String? val) =>
    val != null && AppRegex.userNameRegEx.hasMatch(val.trim())
    ? null
    : S.current.invalidUserName;

String? phoneNumberValidator(String? val) =>
    // AppRegex.phoneNumberRegEx.hasMatch(val.trim())
    val != null && val.trim().isNotEmpty ? null : S.current.invalidPhoneNumber;

String? syrianPhoneNumberValidator(String? phoneNumber) {
  if (phoneNumber == null || phoneNumber.trim().isEmpty) {
    return S.current.invalidPhoneNumber;
  }

  // Remove unwanted characters (keep digits and +)
  final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

  if (!AppRegex.syrianPhoneRegEx.hasMatch(cleaned)) {
    return S.current.invalidSyrianPhone;
  }

  return null; // Valid
}

//  validate text aria
String? textAriaValidator(String? val) {
  if (val == null || val.isEmpty) {
    return S.current.textAreaEmpty;
  }
  if ((val.trim()).length < 50) {
    return S.current.messageMinLength;
  }
  return null;
}

PasswordStrength getPasswordStrength(String password) {
  int score = 0;

  if (password.length >= AppConfigs.passwordMinLength) score++;
  if (AppRegex.numberRegEx.hasMatch(password)) score++;
  if (AppRegex.symbolRegEx.hasMatch(password)) score++;
  if (AppRegex.uppercaseRegEx.hasMatch(password)) score++;
  if (password.length >= AppConfigs.veryStrongPasswordLength) score++;

  switch (score) {
    case 0:
    case 1:
      return PasswordStrength.weak;
    case 2:
    case 3:
      return PasswordStrength.medium;
    case 4:
      return PasswordStrength.strong;
    case 5:
      return PasswordStrength.veryStrong;
    default:
      return PasswordStrength.weak;
  }
}

String? pinDigitValidator(String? val) {
  if (val == null || val.trim().isEmpty) {
    return S.current.fieldRequired;
  }
  if (val.trim().length != AppConfigs.pinDigitLength) {
    return S.current.codeMustBe6Digits;
  }
  if (!AppRegex.pinRegEx.hasMatch(val.trim())) {
    return S.current.codeMustBeDigitsOnly;
  }
  return null;
}
