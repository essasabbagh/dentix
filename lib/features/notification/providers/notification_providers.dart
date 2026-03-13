import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/features/auth/providers/auth_provider.dart';
import 'package:template/initialize_app.dart';

import '../models/notification_model.dart';
import '../services/notification_storage_service.dart';

// Provider for the notification storage service
final notificationStorageProvider = Provider<NotificationStorageService>((ref) {
  final store = locator<GetStorage>();
  return NotificationStorageService(store);
});

// Provider for all notifications for a user
final userNotificationsProvider = FutureProvider<List<NotificationModel>>((
  ref,
) async {
  final profileState = ref.watch(authNotifierProvider.notifier);
  /* 
    Save notification to local storage
    If the user is logged in, save the notification with user id.
    If the user is not logged in, save the notification with user id as '0'.
  */
  final String userId = '${profileState.user?.id ?? '0'}';

  return ref.read(notificationStorageProvider).getNotificationsByUserId(userId);
});

// Provider for unread count
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final profileState = ref.watch(authNotifierProvider.notifier);
  /* 
    Save notification to local storage
    If the user is logged in, save the notification with user id.
    If the user is not logged in, save the notification with user id as '0'.
  */
  final String userId = '${profileState.user?.id ?? '0'}';

  return ref.read(notificationStorageProvider).getUnreadCount(userId);
});

// Notification controller provider to handle actions
final notificationControllerProvider = Provider<NotificationController>((ref) {
  final profileState = ref.watch(authNotifierProvider.notifier);
  /* 
    Save notification to local storage
    If the user is logged in, save the notification with user id.
    If the user is not logged in, save the notification with user id as '0'.
  */
  final String userId = '${profileState.user?.id ?? '0'}';
  return NotificationController(ref, userId);
});

// Controller class to handle notification actions
class NotificationController {
  NotificationController(this.ref, this.userId);
  final Ref ref;
  final String userId;

  // Add a new notification
  Future<NotificationModel> addNotification(
    NotificationModel data,
  ) async {
    final newNotification = await ref
        .read(notificationStorageProvider)
        .saveNotification(data);

    // Invalidate providers to refresh lists
    ref.invalidate(userNotificationsProvider);
    ref.invalidate(unreadNotificationsCountProvider);

    return newNotification;
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    final result = await ref
        .read(notificationStorageProvider)
        .markAsRead(notificationId);

    if (result) {
      // Invalidate providers to refresh lists
      ref.invalidate(userNotificationsProvider);
      ref.invalidate(unreadNotificationsCountProvider);
    }

    return result;
  }

  // Mark all as read
  Future<int> markAllAsRead() async {
    final count = await ref
        .read(notificationStorageProvider)
        .markAllAsRead(userId);

    if (count > 0) {
      // Invalidate providers to refresh lists
      ref.invalidate(userNotificationsProvider);
      ref.invalidate(unreadNotificationsCountProvider);
    }

    return count;
  }
}
