import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:dentix/core/backup/backup_repository.dart';
import 'package:dentix/core/backup/google_drive_service.dart';

final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) {
  return GoogleDriveService();
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final service = ref.watch(googleDriveServiceProvider);
  return BackupRepository(service);
});

final googleSignInStateProvider =
    StateNotifierProvider<GoogleSignInNotifier, GoogleSignInState>((ref) {
      final repository = ref.watch(backupRepositoryProvider);
      final notifier = GoogleSignInNotifier(repository);
      notifier.checkSignInStatus();
      return notifier;
    });

class GoogleSignInNotifier extends StateNotifier<GoogleSignInState> {
  GoogleSignInNotifier(this._repository) : super(const GoogleSignInState()) {
    _init();
  }

  final BackupRepository _repository;

  void _init() {
    _repository.onCurrentUserChanged.listen((user) {
      state = state.copyWith(
        isSignedIn: user != null,
        user: user,
        isLoading: false,
      );
    });
    checkSignInStatus();
  }

  Future<void> checkSignInStatus() async {
    state = state.copyWith(isLoading: true);
    await _repository.isSignedIn();
    state = state.copyWith(isLoading: false);
  }

  Future<bool> signIn() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _repository.signIn();
      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error: 'فشل تسجيل الدخول',
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
  }
}

class GoogleSignInState {
  const GoogleSignInState({
    this.isSignedIn = false,
    this.isLoading = false,
    this.error,
    this.user,
  });

  final bool isSignedIn;
  final bool isLoading;
  final String? error;
  final GoogleSignInAccount? user;

  GoogleSignInState copyWith({
    bool? isSignedIn,
    bool? isLoading,
    String? error,
    GoogleSignInAccount? user,
  }) {
    return GoogleSignInState(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

final backupListProvider = FutureProvider<List<BackupInfo>>((ref) async {
  final repository = ref.watch(backupRepositoryProvider);
  final isSignedIn = await repository.isSignedIn();
  if (!isSignedIn) return [];
  return repository.getBackups();
});

final backupNotifierProvider =
    StateNotifierProvider<BackupNotifier, BackupState>((ref) {
      final repository = ref.watch(backupRepositoryProvider);
      return BackupNotifier(repository, ref);
    });

class BackupNotifier extends StateNotifier<BackupState> {
  BackupNotifier(this._repository, this._ref) : super(const BackupState());

  final BackupRepository _repository;
  final Ref _ref;

  Future<bool> createBackup() async {
    state = state.copyWith(isCreatingBackup: true, error: null);
    try {
      final success = await _repository.createBackup();
      if (success) {
        state = state.copyWith(isCreatingBackup: false);
        _ref.invalidate(backupListProvider);
        return true;
      } else {
        state = state.copyWith(
          isCreatingBackup: false,
          error: 'فشل إنشاء النسخة الاحتياطية',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isCreatingBackup: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> restoreBackup(BackupInfo backup) async {
    state = state.copyWith(isRestoring: true, error: null);
    try {
      final success = await _repository.restoreBackup(backup);
      if (success) {
        state = state.copyWith(isRestoring: false);
        return true;
      } else {
        state = state.copyWith(
          isRestoring: false,
          error: 'فشل استعادة النسخة الاحتياطية',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isRestoring: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

class BackupState {
  const BackupState({
    this.isCreatingBackup = false,
    this.isRestoring = false,
    this.error,
  });

  final bool isCreatingBackup;
  final bool isRestoring;
  final String? error;

  BackupState copyWith({
    bool? isCreatingBackup,
    bool? isRestoring,
    String? error,
  }) {
    return BackupState(
      isCreatingBackup: isCreatingBackup ?? this.isCreatingBackup,
      isRestoring: isRestoring ?? this.isRestoring,
      error: error,
    );
  }
}
