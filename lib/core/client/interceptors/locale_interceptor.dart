import 'package:dio/dio.dart';

import 'package:template/configs/app_configs.dart';
import 'package:template/core/constants/keys.dart';
import 'package:template/core/data/storage_service.dart';

class LocaleInterceptor extends Interceptor {
  LocaleInterceptor(this._storage);

  final StorageService _storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final langCode = _storage.read(languageCodeKey);

    options.headers['Accept-Language'] = (langCode.isEmpty)
        ? AppConfigs.defaultLocale
        : langCode;

    handler.next(options);
  }
}
