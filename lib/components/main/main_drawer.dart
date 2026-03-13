// import 'package:flutter/material.dart';

// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:template/core/locale/generated/l10n.dart';
// import 'package:template/core/router/app_routes.dart';
// import 'package:template/features/auth/providers/auth_provider.dart';

// import 'app_divider.dart';

// class MainDrawer extends ConsumerWidget {
//   const MainDrawer({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return SafeArea(
//       bottom: false,
//       child: Drawer(
//         child: ListView(
//           children: <Widget>[
//             GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//                 context.goNamed(AppRoutes.profile.name);
//               },
//               child: DrawerHeader(
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   // border: Border(
//                   //   bottom: BorderSide(
//                   //     color: Colors.red.withValues(alpha: 0.1),
//                   //   ),
//                   // ),
//                 ),
//                 padding: EdgeInsets.zero,
//                 child: const Icon(Icons.person),
//                 // child: Image(
//                 //   image: AssetImage(ImageAssets.mainImage),
//                 //   fit: BoxFit.cover,
//                 // ),
//               ),
//             ),
//             // const AppDivider(),
//             ListTile(
//               leading: const Icon(Icons.home),
//               title: Text(S.of(context).home),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.goNamed(AppRoutes.home.name);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.category),
//               title: Text(S.of(context).categories),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.pushNamed(AppRoutes.category.name);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.search),
//               title: Text(S.of(context).searchScreen),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.pushNamed(AppRoutes.search.name);
//               },
//             ),
//             const AppDivider(),
//             ListTile(
//               leading: const Icon(Icons.help_outline),
//               title: Text(S.of(context).contactUs),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.pushNamed(AppRoutes.help.name);
//               },
//             ),
//             const AppDivider(),
//             ListTile(
//               leading: Icon(
//                 Icons.exit_to_app,
//                 color: Theme.of(context).colorScheme.error,
//               ),
//               title: Text(
//                 S.of(context).logout,
//                 style: TextStyle(color: Theme.of(context).colorScheme.error),
//               ),
//               onTap: () {
//                 // confirm dialog
//                 Navigator.pop(context);
//                 ref.read(authNotifierProvider.notifier).logout();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
