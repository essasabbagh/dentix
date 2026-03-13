import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/images.dart';
import '../locale/generated/l10n.dart';

/// Enum for all possible status codes with comprehensive error mapping
enum StatusCode {
  success(HttpStatus.ok),
  noContent(HttpStatus.noContent),
  badRequest(HttpStatus.badRequest),
  unauthorized(HttpStatus.unauthorized),
  forbidden(HttpStatus.forbidden),
  notFound(HttpStatus.notFound),
  timeout(HttpStatus.requestTimeout),
  unprocessableContent(HttpStatus.unprocessableEntity),
  serverError(HttpStatus.internalServerError),
  noInternet(-1),
  cancel(-2),
  cacheError(-3),
  formatError(-4),
  connectionError(-5),
  noNotifications(-6),
  unknown(-99);

  const StatusCode(this.code);
  final int code;

  /// Factory method to create StatusCode from HTTP status code
  static StatusCode fromCode(int? code) {
    return StatusCode.values.firstWhere(
      (status) => status.code == code,
      orElse: () => StatusCode.unknown,
    );
  }

  /// Get localized error message for each status code
  String get message => switch (this) {
    noContent => '',
    success => '',
    noInternet => S.current.noInternetConnectionAvailable,
    timeout => S.current.requestTimeoutPleaseTryAgain,
    badRequest => S.current.invalidRequestPleaseCheckYourInput,
    unauthorized => S.current.authenticationRequiredPleaseLogin,
    forbidden => S.current.accessDeniedYouDontHavePermission,
    notFound => S.current.requestedResourceNotFound,
    serverError => S.current.serverErrorPleaseTryAgainLater,
    unknown => S.current.anUnexpectedErrorOccurred,
    unprocessableContent => S.current.unableToProcessTheRequest,
    cancel => S.current.requestWasCancelled,
    cacheError => S.current.cacheErrorOccurred,
    formatError => S.current.dataFormatError,
    noNotifications => S.current.noNotificationsFound,
    connectionError => S.current.connectionErrorOccurred,
  };

  /// Get user-friendly title for error dialogs/widgets
  String get title => switch (this) {
    noInternet => S.current.noInternetConnection,
    timeout => S.current.requestTimedOut,
    badRequest => S.current.invalidRequest,
    unauthorized => S.current.authenticationRequired,
    forbidden => S.current.accessDenied,
    notFound => S.current.notFound,
    serverError => S.current.serverError,
    unknown => S.current.somethingWentWrong,
    unprocessableContent => S.current.processingError,
    cancel => S.current.requestCancelled,
    cacheError => S.current.cacheError,
    formatError => S.current.dataError,
    noNotifications => S.current.noNotificationsFound,
    connectionError => S.current.connectionError,
    _ => S.current.error,
  };

  /// Get appropriate icon for each error type
  IconData get icon => switch (this) {
    noInternet => Icons.wifi_off_outlined,
    timeout => Icons.timer_off_outlined,
    badRequest => Icons.warning_outlined,
    unauthorized => Icons.lock_outline,
    forbidden => Icons.block_outlined,
    notFound => Icons.search_off_outlined,
    serverError => Icons.dns_outlined,
    cancel => Icons.cancel_outlined,
    cacheError => Icons.storage_outlined,
    formatError => Icons.code_off_outlined,
    noNotifications => Icons.search_off_outlined,
    connectionError => Icons.signal_wifi_connected_no_internet_4_outlined,
    _ => Icons.error_outline,
  };

  /// Get appropriate color for each error type
  Color get color => switch (this) {
    noInternet => Colors.orange,
    timeout => Colors.amber,
    badRequest => Colors.blue,
    unauthorized => Colors.red,
    forbidden => Colors.red,
    notFound => Colors.grey,
    serverError => Colors.red,
    cancel => Colors.grey,
    cacheError => Colors.purple,
    formatError => Colors.indigo,
    noNotifications => Colors.grey,
    connectionError => Colors.orange,
    _ => Colors.red,
  };

  // image path for empty state widgets
  String get imagePath => switch (this) {
    noInternet => AppImages.imagesEmptyStateConnectionLost,
    timeout => AppImages.imagesEmptyStateTimeoutReached,
    badRequest => AppImages.imagesEmptyStateSomethingWrong,
    unauthorized => AppImages.imagesEmptyStateUnauthorizedAccess,
    forbidden => AppImages.imagesEmptyStateForbidden,
    notFound => AppImages.imagesEmptyStateNotFound,
    serverError => AppImages.imagesEmptyStateServerError,
    cancel => AppImages.imagesEmptyStateSomethingWrong,
    cacheError => AppImages.imagesEmptyStateSomethingWrong,
    formatError => AppImages.imagesEmptyStateSomethingWrong,
    noNotifications => AppImages.imagesEmptyStateNoNotifications,
    connectionError => AppImages.imagesEmptyStateConnectionLost,
    _ => AppImages.imagesEmptyStateSomethingWrong,
  };

  @override
  String toString() => message;
}
