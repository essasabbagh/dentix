import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/router/app_router.dart';
import 'package:template/core/router/app_routes.dart';
import 'package:template/core/utils/snackbars.dart';

import '../requests/reset_password_request.dart';

import 'auth_provider.dart';

final resetPasswordProvider = ChangeNotifierProvider<ResetPasswordNotifier>(
  ResetPasswordNotifier.new,
);

class ResetPasswordNotifier extends ChangeNotifier {
  ResetPasswordNotifier(this.ref);
  final Ref ref;

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController(
    text: kReleaseMode ? '' : 'john.doe@example.com',
  );
  final emailFocusNode = FocusNode();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // Reset Password
  Future<void> resetPassword() async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        emailFocusNode.unfocus();
        setLoading(true);

        final request = ResetPasswordRequest(
          email: emailController.text.trim(),
        );

        await ref.read(authServiceProvider).resetPassword(request);

        // Proceed to the next screen
        ref
            .read(routerProvider)
            .pushReplacementNamed(
              AppRoutes.resetPasswordConfirm.name,
              queryParameters: {'email': emailController.text.trim()},
            );

        emailController.text = '';
      }
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();

    super.dispose();
  }
}
