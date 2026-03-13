import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/constants/keys.dart';
import 'package:template/core/data/secure_storage_service.dart';
import 'package:template/core/data/storage_service.dart';
import 'package:template/core/utils/snackbars.dart';
import 'package:template/initialize_app.dart';

import '../requests/login_request.dart';

import 'auth_provider.dart';

final loginProvider = ChangeNotifierProvider.autoDispose<LoginNotifier>(
  LoginNotifier.new,
);

class LoginNotifier extends ChangeNotifier {
  LoginNotifier(this.ref);
  final Ref ref;

  final loginFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController(
    text: kReleaseMode ? '' : 'ahmed@example.com',
  );
  final passwordController = TextEditingController(
    text: kReleaseMode ? '' : 'password123',
  );

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // login
  Future<void> login() async {
    try {
      if (loginFormKey.currentState?.validate() ?? false) {
        // must finish the autofill context after login
        TextInput.finishAutofillContext();
        emailFocusNode.unfocus();
        passwordFocusNode.unfocus();
        setLoading(true);

        final request = LoginRequest(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        final res = await ref.read(authServiceProvider).login(request);

        // Update the token
        await locator<StorageService>().saveJson(localUserKey, res.toJson());
        await locator<SecureStorageService>().save(tokenKey, res.token ?? '');

        ref.read(authNotifierProvider.notifier).login(res.data);

        // Proceed to the next screen
        emailController.clear();
        passwordController.clear();
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
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }
}
