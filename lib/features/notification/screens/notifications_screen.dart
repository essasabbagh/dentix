import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/loading/loading_widget.dart';
import 'package:template/core/errors/app_error_widget.dart';
import 'package:template/core/errors/empty_state_widgets.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/utils/snackbars.dart';

import '../providers/notification_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch notifications and unread count
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final controller = ref.read(notificationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).notifications),
        actions: [
          // Show unread count badge
          // Mark all as read button
          IconButton(
            icon: const Icon(
              Icons.done_all,
              // color: Colors.white,
            ),
            onPressed: () async {
              final count = await controller.markAllAsRead();
              if (count > 0) {
                AppSnackBar.info('Marked $count notifications as read');
              }
              ref.refresh(userNotificationsProvider);
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return EmptyStateWidgets.noNotifications();
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return NotificationTile(
                notification: notification,
                onTap: () {
                  if (!notification.isRead) {
                    controller.markAsRead(notification.id);
                  }
                  // Show notification details or navigate to relevant screen
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(notification.title),
                      content: Text(notification.message),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('close'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        loading: LoadingWidget.new,
        error: (error, stackTrace) => AppErrorWidget.fromError(
          error,
          stackTrace,
          onRetry: () => ref.refresh(userNotificationsProvider),
          onGoBack: () => Navigator.pop(context),
          onLogin: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          ),
        ),
      ),
    );
  }
}
