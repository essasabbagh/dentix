// import 'package:flutter/material.dart';

// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:template/core/themes/app_colors.dart';

// class NotificationCard extends StatelessWidget {
//   const NotificationCard({
//     super.key,
//     required this.notification,
//   });

//   final RemoteMessage notification; // Use a data model

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       // Use Card widget for built-in shadow and rounded corners
//       margin: const EdgeInsets.symmetric(
//         vertical: 8,
//         horizontal: 16,
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 8,
//         ),
//         // leading: CustomBadge(
//         //   isVisible: true,
//         //   label: '',
//         //   child: Icon(
//         //     Icons.notifications,
//         //     color: Theme.of(context).primaryColor,
//         //   ),
//         // ),
//         leading: Badge(
//           smallSize: 1,
//           largeSize: 2,
//           isLabelVisible: true,
//           offset: const Offset(16, -8),

//           backgroundColor: AppColors.error600,
//           label: const Text('.'),
//           // label: const Icon(
//           //   Icons.circle,
//           //   size: 1,
//           //   color: AppColors.error400,
//           // ),
//           child: Icon(
//             Icons.notifications,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               notification.notification?.title ?? '',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             // Text(
//             //   DateFormat.yMMMd().format(notification.), // Format the date
//             //   style: const TextStyle(
//             //     fontSize: 12,
//             //     color: Colors.grey,
//             //   ),
//             // ),
//           ],
//         ),
//         subtitle: Text(
//           notification.notification?.body ?? '',
//         ),
//         // trailing: const Icon(
//         //   Icons.circle,
//         //   size: 8,
//         //   color: Colors.red,
//         // ), // Add a chevron
//         onTap: () {
//           // Handle tap action (e.g., navigate to details screen)
//           // print('Notification tapped: ${notification.id}');
//         },
//       ),
//     );
//   }
// }
