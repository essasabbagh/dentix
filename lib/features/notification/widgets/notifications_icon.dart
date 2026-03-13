import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/notification_providers.dart';

class NotificationsIcon extends ConsumerWidget {
  const NotificationsIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> unreadCountAsync = ref.watch(
      unreadNotificationsCountProvider,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: unreadCountAsync.when(
        data: (int count) => count > 0
            ? Badge(
                label: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    // fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
                child: const Icon(Icons.notifications),
              )
            : const Icon(Icons.notifications_none),
        loading: SizedBox.new,
        error: (_, _) => const Icon(Icons.notifications),
      ),
    );
  }
}
