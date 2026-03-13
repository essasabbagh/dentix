import 'package:flutter/material.dart';

import '../constants/images.dart';
import '../locale/generated/l10n.dart';

import 'empty_state_widget.dart';

class EmptyStateWidgets {
  static Widget noData({
    String? title,
    String? subtitle,
    VoidCallback? onRefresh,
  }) {
    return EmptyStateWidget(
      imagePath: AppImages.imagesEmptyStateEmptyList,
      title: title ?? S.current.noDataFound,
      subtitle: subtitle ?? S.current.theresNothingToShowHereYet,
      actionText: onRefresh != null ? S.current.refresh : null,
      onActionPressed: onRefresh,
    );
  }

  static Widget noNetwork({
    String? title,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      imagePath: AppImages.imagesEmptyStateConnectionLost,
      title: title ?? S.current.noInternetConnection,
      subtitle: subtitle ?? S.current.pleaseCheckYourConnectionAndTryAgain,
      actionText: onRetry != null ? S.current.tryAgain : null,
      onActionPressed: onRetry,
    );
  }

  static Widget error({
    String? title,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      imagePath: AppImages.imagesEmptyStateSomethingWrong,
      title: title ?? S.current.somethingWentWrong,
      subtitle: subtitle ?? S.current.weEncounteredAnErrorPleaseTryAgain,
      actionText: onRetry != null ? S.current.retry : null,
      onActionPressed: onRetry,
    );
  }

  // server error
  static Widget serverError({
    String? title,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      imagePath: AppImages.imagesEmptyStateServerError,
      title: title ?? S.current.serverError,
      subtitle:
          subtitle ??
          S.current.theServerIsCurrentlyUnavailablePleaseTryAgainLater,
      actionText: onRetry != null ? S.current.retry : null,
      onActionPressed: onRetry,
    );
  }

  static Widget search({
    String? title,
    String? subtitle,
    VoidCallback? onClear,
  }) {
    return EmptyStateWidget(
      imagePath: AppImages.imagesEmptyStateNoSearchResults,
      title: title ?? S.current.noResultsFound,
      subtitle: subtitle ?? S.current.tryAdjustingYourSearchTerms,
      actionText: onClear != null ? S.current.clearSearch : null,
      onActionPressed: onClear,
    );
  }

  // no notifications
  static Widget noNotifications({
    String? title,
    String? subtitle,
    VoidCallback? onRefresh,
  }) {
    return EmptyStateWidget(
      imagePath: AppImages.imagesEmptyStateNoNotifications,
      title: title ?? S.current.noNotifications,
      subtitle: subtitle ?? S.current.youHaveNoNewNotifications,
      actionText: onRefresh != null ? S.current.refresh : null,
      onActionPressed: onRefresh,
    );
  }

  // time out
  static Widget timeOut({
    String? title,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      imagePath: AppImages.imagesEmptyStateTimeoutReached,
      title: title ?? S.current.requestTimedOut,
      subtitle: subtitle ?? S.current.theRequestTookTooLongToComplete,
      actionText: onRetry != null ? S.current.retry : null,
      onActionPressed: onRetry,
    );
  }
}
