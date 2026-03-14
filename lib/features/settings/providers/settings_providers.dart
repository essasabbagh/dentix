import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:template/core/database/app_database.dart';
import 'package:template/features/patients/providers/patients_providers.dart';

// ─── All settings map ─────────────────────────────────────────────────────

final allSettingsProvider = FutureProvider<Map<String, String>>((ref) async {
  return ref.watch(appDatabaseProvider).settingsDao.getAllSettings();
});

// ─── Individual reactive watchers ─────────────────────────────────────────

final clinicNameProvider = StreamProvider<String>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .settingsDao
      .watchValue('clinic_name')
      .map((v) => v ?? 'عيادة الأسنان');
});

final clinicPhoneProvider = StreamProvider<String>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .settingsDao
      .watchValue('clinic_phone')
      .map((v) => v ?? '');
});

final clinicAddressProvider = StreamProvider<String>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .settingsDao
      .watchValue('clinic_address')
      .map((v) => v ?? '');
});

final currencyProvider = StreamProvider<String>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .settingsDao
      .watchValue('currency')
      .map((v) => v ?? 'ر.س');
});

final doctorNameProvider = StreamProvider<String>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .settingsDao
      .watchValue('doctor_name')
      .map((v) => v ?? 'الدكتور');
});

final themeModeProvider = StreamProvider<String>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .settingsDao
      .watchValue('theme_mode')
      .map((v) => v ?? 'light');
});

// ─── Settings notifier ────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<AsyncValue<void>> {
  SettingsNotifier(this._db) : super(const AsyncValue.data(null));
  final AppDatabase _db;

  Future<void> save(String key, String value) async {
    state = const AsyncValue.loading();
    try {
      await _db.settingsDao.setValue(key, value);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveAll(Map<String, String> settings) async {
    state = const AsyncValue.loading();
    try {
      for (final entry in settings.entries) {
        await _db.settingsDao.setValue(entry.key, entry.value);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<void>>((ref) {
      return SettingsNotifier(ref.watch(appDatabaseProvider));
    });
