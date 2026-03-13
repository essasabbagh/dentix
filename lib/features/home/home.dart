import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/main/main_drawer.dart';
import 'package:template/core/client/client.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/utils/app_log.dart';
import 'package:template/core/router/app_routes.dart';
import 'package:template/core/utils/snackbars.dart';
import 'package:template/features/auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).homeScreen),
        actions: [
          IconButton(
            onPressed: ref.read(authNotifierProvider.notifier).logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.of(context).welcomeToTheHomeScreen),
            TextButton(
              onPressed: () {
                context.pushNamed(AppRoutes.settings.name);
              },
              child: Text(S.of(context).settings),
            ),
            TextButton(
              onPressed: () {
                context.pushNamed(AppRoutes.profile.name);
              },
              child: Text(S.of(context).profile),
            ),
            TextButton(
              onPressed: () {
                ref.watch(apiClientProvider).get('/');
              },
              child: Text(S.of(context).test),
            ),
            TextButton(
              onPressed: () {
                AppSnackBar.error(
                  'Failed to connect to server',
                  actionLabel: 'Retry',
                  onAction: () {
                    // Retry connection
                    AppLog.error('connection: ');
                  },
                );
              },
              child: const Text('AppSnackBar'),
            ),
          ],
        ),
      ),
    );
  }
}
