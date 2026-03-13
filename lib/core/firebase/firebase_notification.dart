// import 'dart:async';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:template/configs/app_configs.dart';
// import 'package:template/core/data/storage_service.dart';
// import 'package:template/core/keys/keys.dart';
// import 'package:template/core/log/app_log.dart';
// import 'package:template/features/auth/models/auth_model.dart';
// import 'package:template/features/notification/models/notification_model.dart';
// import 'package:template/features/notification/providers/notification_providers.dart';
// import 'package:template/initialize_app.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
//   await NotificationService.instance.setupFlutterNotifications();
//   await NotificationService.instance.showNotification(msg);
// }

// class NotificationService {
//   NotificationService._();

//   static final NotificationService instance = NotificationService._();

//   final _messaging = FirebaseMessaging.instance;
//   final _localNotifications = FlutterLocalNotificationsPlugin();
//   bool _isFlutterLocalNotificationsInitialized = false;

//   Future<void> initialize() async {
//     AppLog.debug('Notification Service initialize');

//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );

//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // Request permission
//     await _requestPermission();

//     // Setup message handlers
//     // no need any more
//     // await _setupMessageHandlers();

//     await _subscribeToTopic();

//     // Get FCM token
//     await _getToken();
//   }

//   Future<void> _requestPermission() async {
//     // ignore: unused_local_variable
//     final settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//       announcement: false,
//       carPlay: false,
//       criticalAlert: false,
//     );
//   }

//   Future<void> setupFlutterNotifications() async {
//     if (_isFlutterLocalNotificationsInitialized) {
//       return;
//     }

//     // android setup
//     const channel = AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.high,
//     );

//     await _localNotifications
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(channel);

//     const initializationSettingsAndroid = AndroidInitializationSettings(
//       '@drawable/logo',
//     );

//     // ios setup
//     const initializationSettingsDarwin = DarwinInitializationSettings();

//     const initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//     );

//     // flutter notification setup
//     await _localNotifications.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {},
//     );

//     _isFlutterLocalNotificationsInitialized = true;
//   }

//   Future<void> showNotification(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     AppLog.debug('notification.title: ${notification?.title}');

//     if (notification != null) {
//       await _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'high_importance_channel',
//             'High Importance Notifications',
//             channelDescription:
//                 'This channel is used for important notifications.',
//             importance: Importance.high,
//             priority: Priority.high,
//             icon: '@drawable/logo',
//           ),
//           iOS: DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//         payload: message.data.toString(),
//       );

//       /*
//         Save notification to local storage
//         If the user is logged in, save the notification with user id.
//         If the user is not logged in, save notification with user id as '0'.
//       */
//       String? userId;
//       // Save notification to local storage by user id
//       final storageService = locator<StorageService>();

//       final data = storageService.readJson(localUserKey);

//       if (data != null) {
//         final userData = AuthModel.fromJson(data).data;
//         userId = '${userData?.id ?? 0}';
//       }

//       ProviderScope.containerOf(rootNavigatorKey.currentContext!)
//           .read(notificationControllerProvider)
//           .addNotification(
//             NotificationModel(
//               id: '${message.messageId}',
//               title: notification.title ?? '',
//               message: notification.body ?? '',
//               createdAt: DateTime.now(),
//               userId: userId ?? '0',
//               isRead: false,
//               data: message.data,
//             ),
//           );
//     }
//   }

//   Future<void> _setupMessageHandlers() async {
//     // foreground message
//     FirebaseMessaging.onMessage.listen(showNotification);

//     // background message
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

//     // opened app
//     final initialMessage = await _messaging.getInitialMessage();
//     if (initialMessage != null) {
//       _handleBackgroundMessage(initialMessage);
//     }
//   }

//   void _handleBackgroundMessage(RemoteMessage message) {
//     AppLog.debug('message: ${message.notification?.title}');
//     AppLog.debug('message: ${message.notification?.body}');
//     if (message.data['type'] == 'chat') {
//       // open chat screen
//     }
//   }

//   Future<String?> _getToken() async {
//     try {
//       String? token;
//       FirebaseMessaging.instance.getToken().then((String? token) {
//         AppLog.debug('FCM Token: $token');
//         // save the new token to your server
//         // final notificationStroage = locator<NotificationStroage>();
//         // notificationStroage.saveFCMToken(token ?? '');
//       });

//       FirebaseMessaging.instance.onTokenRefresh.listen((String? token) {
//         AppLog.debug('onTokenRefresh: $token');

//         // save the new token to your server
//         // final notificationStroage = locator<NotificationStroage>();
//         // notificationStroage.saveFCMToken(token ?? '');
//       });

//       return token;
//     } catch (e) {
//       AppLog.error('getToken error: $e');
//       return null;
//     }
//   }

//   Future<void> _subscribeToTopic([String? topic]) async {
//     await FirebaseMessaging.instance.subscribeToTopic(
//       topic ?? AppConfigs.topic,
//     );
//   }

//   // Future<void> _unsubscribeFromTopic([String? topic]) async {
//   //   await FirebaseMessaging.instance.unsubscribeFromTopic(
//   //     topic ?? AppConfigs.topic,
//   //   );
//   // }
// }
