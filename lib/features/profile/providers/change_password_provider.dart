import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/utils/app_log.dart';
import 'package:template/core/utils/snackbars.dart';
import 'package:template/features/auth/providers/auth_provider.dart';

import '../requests/change_password_request.dart';

import 'profile_provider.dart';

final changePasswordProvider =
    ChangeNotifierProvider.autoDispose<ChangePasswordNotifier>(
      ChangePasswordNotifier.new,
    );

class ChangePasswordNotifier extends ChangeNotifier {
  ChangePasswordNotifier(this.ref);
  final Ref ref;

  final updatePasswordFormKey = GlobalKey<FormState>();

  final oldPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final oldPasswordFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isConfirmPasswordVisible = false;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  String password = '';

  void onPasswordChanged(String val) {
    password = val;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  // change Password
  Future<void> changePassword() async {
    try {
      if (updatePasswordFormKey.currentState?.validate() ?? false) {
        TextInput.finishAutofillContext();
        oldPasswordFocusNode.unfocus();
        passwordFocusNode.unfocus();
        confirmPasswordFocusNode.unfocus();
        setLoading(true);

        final request = ChangePasswordRequest(
          oldPassword: oldPasswordController.text,
          password: passwordController.text,
          passwordConfirmation: confirmPasswordController.text,
        );

        await ref.read(profileServiceProvider).changePassword(request);

        AppSnackBar.success(S.current.passwordChangedSuccessfully);

        ref.read(authNotifierProvider.notifier).logout();
        AppLog.debug('Account logout.');

        clearFields();
      }
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void clearFields() {
    oldPasswordController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    oldPasswordFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
