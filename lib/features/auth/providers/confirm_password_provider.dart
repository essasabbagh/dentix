import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/utils/validators.dart';
import 'package:template/core/router/app_router.dart';
import 'package:template/core/router/app_routes.dart';
import 'package:template/core/utils/snackbars.dart';
import 'package:template/features/auth/providers/auth_provider.dart';
import 'package:template/features/auth/requests/confirm_reset_password_code_request.dart';

final confirmPasswordProvider = ChangeNotifierProvider.autoDispose
    .family<ConfirmPasswordNotifier, String?>(ConfirmPasswordNotifier.new);

class ConfirmPasswordNotifier extends ChangeNotifier {
  ConfirmPasswordNotifier(this.ref, this.email) {
    codeFocusNode.requestFocus();
  }

  final String? email;
  final Ref ref;

  final codeController = TextEditingController();
  final codeFocusNode = FocusNode();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorText;
  String? get errorText => _errorText;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void setError(String? val) {
    _errorText = val;
    notifyListeners();
  }

  // Reset Password
  Future<void> confirmCode() async {
    try {
      if (pinDigitValidator(codeController.text) != null) {
        throw pinDigitValidator(codeController.text) ?? '';
      }

      codeFocusNode.unfocus();
      setLoading(true);

      final request = ConfirmResetPasswordCodeRequest(
        email: email ?? '',
        resetCode: codeController.text,
      );

      await ref.read(authServiceProvider).confirmResetPasswordCode(request);

      // Proceed to the next screen
      ref
          .read(routerProvider)
          .pushNamed(
            AppRoutes.updatePassword.name,
            queryParameters: {
              'email': email ?? '',
              'resetCode': codeController.text,
            },
          );

      codeController.text = '';
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }
}
