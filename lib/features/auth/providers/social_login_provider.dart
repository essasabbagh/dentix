import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/data/secure_storage_service.dart';
import 'package:template/core/data/storage_service.dart';
import 'package:template/core/constants/keys.dart';
import 'package:template/core/utils/snackbars.dart';
import 'package:template/features/auth/providers/auth_provider.dart';
import 'package:template/initialize_app.dart';

final socialLoginProvider = ChangeNotifierProvider<SocialLoginNotifier>(
  SocialLoginNotifier.new,
);

class SocialLoginNotifier extends ChangeNotifier {
  SocialLoginNotifier(this.ref);

  final Ref ref;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> socialLogin(String idToken, String accesstoken) async {
    try {
      setLoading(true);
      // final String? token = await FirebaseMessaging.instance.getToken();
      final res = await ref
          .read(authServiceProvider)
          .socialLogin(idToken, accesstoken);
      // Update the token
      final storageService = locator<StorageService>();
      final secureStorageService = locator<SecureStorageService>();

      await storageService.saveJson(localUserKey, res.toJson());
      await secureStorageService.save(tokenKey, res.token ?? '');
      await ref.read(authNotifierProvider.notifier).login(res.data);
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
