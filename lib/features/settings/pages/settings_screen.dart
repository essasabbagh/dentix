import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/main/app_divider.dart';
import 'package:template/core/client/client.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/utils/snackbars.dart';

import '../widgets/locale_menu.dart';
import '../widgets/theme_menu.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).theme,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            const ThemeDropdown(),
            const SizedBox(height: 16),
            Text(
              S.of(context).locale,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            const LocaleDropdown(),
            const SizedBox(height: 8),
            const AppDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    S.of(context).cache,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final client = ref.watch(apiClientProvider);
                    await client.clearCache();
                    // Show a success message if needed
                    AppSnackBar.success(
                      // ignore: use_build_context_synchronously
                      S.of(context).cacheClearedSuccessfully,
                    );
                  },
                  child: Text(S.of(context).clearCache),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
