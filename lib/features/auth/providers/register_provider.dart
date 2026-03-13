import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/router/app_router.dart';
import 'package:template/core/router/app_routes.dart';
import 'package:template/core/utils/snackbars.dart';

import '../requests/register_request.dart';

import 'auth_provider.dart';

final registerProvider = ChangeNotifierProvider<RegisterNotifier>(
  RegisterNotifier.new,
);

class RegisterNotifier extends ChangeNotifier {
  RegisterNotifier(this.ref);

  final Ref ref;

  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController(
    text: kReleaseMode ? '' : 'John',
  );
  final lastNameController = TextEditingController(
    text: kReleaseMode ? '' : 'Doe',
  );
  final emailController = TextEditingController(
    text: kReleaseMode ? '' : 'john.doe@example.com',
  );
  final passwordController = TextEditingController(
    text: kReleaseMode ? '' : 'Password123456789!',
  );
  final confirmPasswordController = TextEditingController(
    text: kReleaseMode ? '' : 'Password123456789!',
  );

  final firstNameFocusNode = FocusNode();
  final lastNameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  bool _isChecked = false;
  bool get isChecked => _isChecked;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isConfirmPasswordVisible = false;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  String password = '';

  void toggleTermsAndConditions(bool? val) {
    _isChecked = val ?? false;
    notifyListeners();
  }

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

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // register
  Future<void> register() async {
    try {
      if (!isChecked) {
        AppSnackBar.error(S.current.pleaseAcceptTermsAndConditions);
        return;
      }
      if (formKey.currentState?.validate() ?? false) {
        TextInput.finishAutofillContext();
        emailFocusNode.unfocus();
        passwordFocusNode.unfocus();
        confirmPasswordFocusNode.unfocus();
        setLoading(true);
        // final String? token = await NotificationService.instance.getToken();

        final request = RegisterRequest(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          passwordConfirmation: confirmPasswordController.text.trim(),
          accepted: '1',
        );
        // final res =
        await ref.read(authServiceProvider).register(request);

        ref
            .read(routerProvider)
            .pushNamed(
              AppRoutes.registerConfirm.name,
              queryParameters: {'email': emailController.text.trim()},
            );

        clearFields();
      }
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
