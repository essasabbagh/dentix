import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/router/app_router.dart';
import 'package:template/core/router/app_routes.dart';

import '../requests/confirm_register_code_request.dart';

import 'auth_provider.dart';

final registerConfirmNotifier =
    ChangeNotifierProvider.autoDispose<RegisterConfirmNotifier>(
      RegisterConfirmNotifier.new,
    );

class RegisterConfirmNotifier extends ChangeNotifier {
  RegisterConfirmNotifier(this.ref) {
    codeFocusNode.requestFocus();
  }
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

  // verify Email
  Future<void> verifyEmail(String email) async {
    try {
      setError(null);
      setLoading(true);

      final code = codeController.text;

      final request = ConfirmRegisterCodeRequest(
        email: email,
        verificationCode: code,
      );

      await ref.read(authServiceProvider).confirmRegisterCode(request);

      codeController.text = '';
      ref.read(routerProvider).goNamed(AppRoutes.login.name);
    } catch (e) {
      setError(e.toString());
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
