import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/client/client.dart';
import 'package:template/core/constants/keys.dart';
import 'package:template/core/data/secure_storage_service.dart';
import 'package:template/core/data/storage_service.dart';
import 'package:template/features/auth/models/user_data.dart';
import 'package:template/features/auth/services/auth_service.dart';
import 'package:template/initialize_app.dart';

final storageService = locator<StorageService>();
final secureStorageService = locator<SecureStorageService>();

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.read(apiClientProvider)),
);

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

final userProvider = StateProvider<UserData?>(
  (ref) => ref.watch(authNotifierProvider.notifier).user,
);

class AuthNotifier extends AsyncNotifier<bool> {
  UserData? user;

  @override
  FutureOr<bool> build() async {
    // TODO : Implement a more robust authentication check
    return true;
    try {
      final res = await ref.read(authServiceProvider).getProfile();
      user = res;
      return user?.id != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> login(UserData? user) async {
    this.user = user;
    state = const AsyncValue.data(true);
  }

  Future<void> logout() async {
    user = null;

    Future.wait([
      ref.read(authServiceProvider).logout(),
      storageService.remove(localUserKey),
      secureStorageService.remove(tokenKey),
    ]);

    state = const AsyncValue.data(false);
  }

  Future<void> refreshUser() async {
    try {
      final res = await ref.read(authServiceProvider).getProfile();
      user = res;
      ref.read(userProvider.notifier).state = user;
      state = const AsyncValue.data(true);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
