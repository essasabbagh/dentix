import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:dentix/core/locale/generated/l10n.dart';

import '../providers/backup_providers.dart';
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
      body: SingleChildScrollView(
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
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              S.of(context).backupRestore,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const _BackupSection(),
          ],
        ),
      ),
    );
  }
}

class _BackupSection extends ConsumerWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signInState = ref.watch(googleSignInStateProvider);
    final backupState = ref.watch(backupNotifierProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_upload, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).googleDriveBackup,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (signInState.isSignedIn)
                        Text(
                          signInState.user?.displayName ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!signInState.isSignedIn) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: signInState.isLoading
                      ? null
                      : () async {
                          final success = await ref
                              .read(googleSignInStateProvider.notifier)
                              .signIn();
                          if (success) {
                            ref.invalidate(backupListProvider);
                          }
                        },
                  icon: signInState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    signInState.isLoading
                        ? S.of(context).signingIn
                        : S.of(context).signInWithGoogle,
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: backupState.isCreatingBackup
                          ? null
                          : () async {
                              final success = await ref
                                  .read(backupNotifierProvider.notifier)
                                  .createBackup();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? S.of(context).backupCreated
                                          : S.of(context).backupFailed,
                                    ),
                                    backgroundColor: success
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                              }
                            },
                      icon: backupState.isCreatingBackup
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.backup),
                      label: Text(
                        backupState.isCreatingBackup
                            ? S.of(context).creatingBackup
                            : S.of(context).createBackup,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRestoreDialog(context, ref),
                      icon: const Icon(Icons.restore),
                      label: Text(S.of(context).restoreBackup),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    await ref
                        .read(googleSignInStateProvider.notifier)
                        .signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(S.of(context).signOut),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _RestoreBackupDialog(),
    );
  }
}

class _RestoreBackupDialog extends ConsumerWidget {
  const _RestoreBackupDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupsAsync = ref.watch(backupListProvider);

    return AlertDialog(
      title: Text(S.of(context).restoreBackup),
      content: SizedBox(
        width: double.maxFinite,
        child: backupsAsync.when(
          data: (backups) {
            if (backups.isEmpty) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: Text(S.of(context).noBackupsFound),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final backup = backups[index];
                return ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: Text(backup.name),
                  subtitle: Text(
                    '${backup.formattedSize} - '
                    '${DateFormat.yMd().add_Hm().format(backup.modifiedTime)}',
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(S.of(context).confirmRestore),
                        content: Text(S.of(context).restoreWarning),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(S.of(context).cancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(S.of(context).restore),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      final success = await ref
                          .read(backupNotifierProvider.notifier)
                          .restoreBackup(backup);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? S.of(context).restoreCompleted
                                  : S.of(context).restoreFailed,
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SizedBox(
            height: 100,
            child: Center(
              child: Text('$e'),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).cancel),
        ),
      ],
    );
  }
}
