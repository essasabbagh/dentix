import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/router/app_router.dart';
import 'package:template/core/router/app_routes.dart';
import 'package:template/core/utils/snackbars.dart';

import '../helpers/reset_helper.dart';
import '../requests/update_password_request.dart';

import 'auth_provider.dart';

typedef EmailCode = Map<String, String?>;

final updatePasswordProvider = ChangeNotifierProvider.autoDispose
    .family<UpdatePasswordNotifier, String>(UpdatePasswordNotifier.new);

class UpdatePasswordNotifier extends ChangeNotifier {
  UpdatePasswordNotifier(this.ref, this.reset) {
    passwordFocusNode.requestFocus();
  }

  final Ref ref;
  final String reset;

  final updatePasswordFormKey = GlobalKey<FormState>();

  final passwordController = TextEditingController(
    text: kReleaseMode ? '' : 'Qwer!2345QWerew',
  );
  final confirmPasswordController = TextEditingController(
    text: kReleaseMode ? '' : 'Qwer!2345QWerew',
  );

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

  // Reset Password
  Future<void> updatePassword() async {
    try {
      if (updatePasswordFormKey.currentState?.validate() ?? false) {
        TextInput.finishAutofillContext();
        passwordFocusNode.unfocus();
        confirmPasswordFocusNode.unfocus();
        setLoading(true);

        // Decode back
        final decoded = ResetHelper.decode(reset);

        final request = UpdatePasswordRequest(
          email: decoded.getEmail(),
          resetCode: decoded.getCode(),
          password: passwordController.text.trim(),
          passwordConfirmation: confirmPasswordController.text.trim(),
        );

        await ref.read(authServiceProvider).updatePassword(request);

        AppSnackBar.success(S.current.updatePasswordSuccess);

        ref.read(routerProvider).goNamed(AppRoutes.login.name);

        clearFields();
      }
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void clearFields() {
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
