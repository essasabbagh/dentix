import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:template/configs/app_configs.dart';
import 'package:template/core/constants/network.dart';
import 'package:template/core/data/storage_service.dart';
import 'package:template/core/utils/app_log.dart';
import 'package:template/initialize_app.dart';

import 'interceptors/cache_interceptor.dart';
import 'interceptors/locale_interceptor.dart';
import 'interceptors/safe_error_interceptor.dart';

// Provide Dio instance
final dioProvider = Provider<Dio>((ref) => Dio());

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Create a singleton class to contain all Dio methods and helper functions
class ApiClient {
  CancelToken cancelToken = CancelToken();

  BaseOptions options = BaseOptions(
    baseUrl: AppConfigs.baseUrl,
    receiveTimeout: timeoutDuration,
    connectTimeout: timeoutDuration,
    sendTimeout: timeoutDuration,
    followRedirects: false,
    responseType: ResponseType.json,
    contentType: Headers.jsonContentType,
    // validateStatus: (status) => status! <= 500,
    headers: {
      'Accept': 'application/json',
      // 'Cache-Control': 'max-age=604800',
    },
  );

  late final Dio _dio = Dio()
    ..options = options
    ..interceptors.addAll([
      // AuthInterceptor(),
      DioCacheInterceptor(options: cacheOptions),
      LocaleInterceptor(locator<StorageService>()),
      PrettyDioLogger(
        enabled: kDebugMode,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        request: true,
        error: true,
        compact: true,
        maxWidth: 90,
        // filter: (options, args) {
        //     if (options.path.contains('/ad')) {
        //       return true;
        //     }
        //   return false;
        // },
      ),
      SafeErrorInterceptor(),
    ]);

  Future<void> clearCache() async {
    try {
      await cacheOptions.store?.clean(); // Clears all cache
      AppLog.success('Cache cleared successfully');
    } catch (e) {
      AppLog.error('Error clearing cache: $e');
    }
  }

  /// Get Method
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool isCached = false,
  }) async {
    // Merge provided options with cache settings
    final effectiveOptions = _mergeOptions(options, isCached);

    // Send the GET request with the merged options
    final response = await _dio.get(
      path,
      queryParameters: queryParameters
        // Remove null values from query params
        ?..removeWhere((_, value) => value == null),
      options: effectiveOptions,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );

    return response;
  }

  /// Merges custom options with cache settings based on `isCached`
  Options _mergeOptions(Options? options, bool isCached) {
    // Define the caching policy based on the `isCached` flag
    final cacheOption = cacheOptions
        .copyWith(
          // Enable/disable caching
          policy: isCached ? CachePolicy.forceCache : CachePolicy.noCache,
          // Ensures cache duration remains as default
          maxStale: null,
        )
        .toOptions();

    // Merge user-defined options with the cache options
    return options?.copyWith(
          extra: {
            ...?options.extra,
            ...?cacheOption.extra,
          }, // Merge extra fields
          headers: {
            ...?options.headers,
            ...?cacheOption.headers,
          }, // Merge headers
        ) ??
        cacheOption; // If no custom options, return cache settings
  }

  /// Post Method
  Future<Response> post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final Response response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  /// Put Method
  Future<Response> put(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final Response response = await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  /// Delete Method
  Future<Response> delete(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final Response response = await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return response;
  }

  /// 🔹 DOWNLOAD DIO (NO CACHE ❗)
  late final Dio _downloadDio = Dio()
    ..options = options
    ..interceptors.addAll({
      // AuthInterceptor(),
      PrettyDioLogger(
        enabled: kDebugMode,
        requestBody: false,
        responseBody: false,
      ),
    });

  // ----------------------------------------
  // DOWNLOAD (SAFE)
  // ----------------------------------------
  Future<Response> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool deleteOnError = true,
  }) async {
    return _downloadDio.download(
      path,
      savePath,
      queryParameters: queryParameters?..removeWhere((_, v) => v == null),
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      deleteOnError: deleteOnError,
    );
  }
}
