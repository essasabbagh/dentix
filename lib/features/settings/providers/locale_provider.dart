import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:dentix/configs/app_configs.dart';
import 'package:dentix/core/constants/keys.dart';
import 'package:dentix/core/data/storage_service.dart';
import 'package:dentix/initialize_app.dart';

final storage = locator<StorageService>();

class LocaleNotifier extends Notifier<Locale> {
  @override
  build() {
    final savedLanguageCode = storage.readString(languageCodeKey);
    return Locale(
      savedLanguageCode.isEmpty ? AppConfigs.defaultLocale : savedLanguageCode,
    );
  }

  /// Change the default locale
  Future<void> changeLocale(Locale? value) async {
    if (value != null) {
      state = value;

      await storage.saveString(languageCodeKey, value.languageCode);
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
