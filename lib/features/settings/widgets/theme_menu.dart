import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:dentix/core/locale/generated/l10n.dart';
import 'package:dentix/features/settings/providers/theme_notifier.dart';

class ThemeDropdown extends ConsumerWidget {
  const ThemeDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    // Theme mode options
    final options = [
      {
        'mode': ThemeMode.light,
        'name': S.of(context).light,
        'icon': Icons.light_mode,
      },
      {
        'mode': ThemeMode.dark,
        'name': S.of(context).dark,
        'icon': Icons.dark_mode,
      },
      {
        'mode': ThemeMode.system,
        'name': S.of(context).system,
        'icon': Icons.settings,
      },
    ];

    return ButtonTheme(
      alignedDropdown: true,
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      child: DropdownButtonFormField<ThemeMode>(
        elevation: 2,
        iconSize: 36,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
        borderRadius: BorderRadius.circular(8.0),
        initialValue: themeMode,
        decoration: const InputDecoration(
          // labelText: 'Theme Mode',
        ),
        onChanged: themeNotifier.setTheme,
        items: options.map((option) {
          return DropdownMenuItem<ThemeMode>(
            value: option['mode'] as ThemeMode,
            child: Row(
              children: [
                Icon(option['icon'] as IconData, size: 20),
                const SizedBox(width: 8),
                Text(option['name'] as String),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
