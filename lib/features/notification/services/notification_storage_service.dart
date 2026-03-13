import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import 'package:template/core/utils/app_log.dart';

import '../models/notification_model.dart';

class NotificationStorageService {
  NotificationStorageService(this._box);

  final GetStorage _box;
  static const String _storageKey = 'user_notifications';

  Future<NotificationModel> saveNotification(
    NotificationModel newNotification,
  ) async {
    final List<NotificationModel> allNotifications = _getAllNotifications();
    allNotifications.add(newNotification);

    AppLog.info(
      'Adding new notification: ${jsonEncode(newNotification.toJson())}',
    ); // Debugging output

    _saveAllNotifications(allNotifications);
    return newNotification;
  }

  Future<List<NotificationModel>> getNotificationsByUserId(
    String userId,
  ) async {
    final List<NotificationModel> allNotifications = _getAllNotifications();
    return allNotifications
        .where((NotificationModel item) => item.userId == userId)
        .toList()
      ..sort(
        (NotificationModel a, NotificationModel b) =>
            b.createdAt.compareTo(a.createdAt),
      );
  }

  Future<bool> markAsRead(String notificationId) async {
    final List<NotificationModel> allNotifications = _getAllNotifications();
    bool updated = false;

    final List<NotificationModel> updatedNotifications = allNotifications.map((
      NotificationModel notification,
    ) {
      if (notification.id == notificationId && !notification.isRead) {
        updated = true;
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    _saveAllNotifications(updatedNotifications);
    return updated;
  }

  Future<int> markAllAsRead(String userId) async {
    final List<NotificationModel> allNotifications = _getAllNotifications();
    int count = 0;

    final List<NotificationModel> updatedNotifications = allNotifications.map((
      NotificationModel notification,
    ) {
      if (notification.userId == userId && !notification.isRead) {
        count++;
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    _saveAllNotifications(updatedNotifications);
    return count;
  }

  Future<int> getUnreadCount(String userId) async {
    final List<NotificationModel> userNotifications =
        await getNotificationsByUserId(userId);
    return userNotifications
        .where((NotificationModel item) => !item.isRead)
        .length;
  }

  List<NotificationModel> _getAllNotifications() {
    final List? storedData = _box.read<List<dynamic>>(_storageKey);

    if (storedData == null) {
      AppLog.info('No notifications found in storage.');
      return <NotificationModel>[];
    }

    try {
      return storedData
          .map((json) => NotificationModel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      AppLog.error('Error decoding notifications: $e');
      return <NotificationModel>[];
    }
  }

  void _saveAllNotifications(List<NotificationModel> notifications) {
    final List<String> notificationsJson = notifications
        .map((NotificationModel item) => jsonEncode(item.toJson()))
        .toList();

    AppLog.info('Saving notifications: $notificationsJson'); // Debugging output

    _box.write(_storageKey, notificationsJson);
  }

  Future<bool> deleteNotification(String notificationId) async {
    final List<NotificationModel> allNotifications = _getAllNotifications();
    final int initialLength = allNotifications.length;

    final List<NotificationModel> filteredNotifications = allNotifications
        .where((NotificationModel item) => item.id != notificationId)
        .toList();

    if (filteredNotifications.length < initialLength) {
      _saveAllNotifications(filteredNotifications);
      return true;
    }
    return false;
  }
}
