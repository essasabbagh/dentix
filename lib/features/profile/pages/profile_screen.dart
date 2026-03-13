import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/images/cached_image.dart';
import 'package:template/components/main/app_divider.dart';
import 'package:template/components/main/main_appbar.dart';
import 'package:template/configs/app_configs.dart';
import 'package:template/core/enums/alert_dialog_type.dart';
import 'package:template/core/extensions/extensions.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/utils/app_log.dart';
import 'package:template/core/router/app_routes.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/core/utils/main_confirm_dialog.dart';
import 'package:template/core/utils/share_utils.dart';
import 'package:template/features/auth/providers/auth_provider.dart';
import 'package:template/features/profile/widgets/profile_item.dart';

import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: MainAppBar(title: S.of(context).profile),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              ClipOval(
                child: CachedImage(
                  '',
                  width: context.width * 0.25,
                  height: context.width * 0.25,
                ),
              ),
              const SizedBox(height: 12),
              ProfileItem(
                icon: Icons.person_outline_rounded,
                title: S.of(context).updateProfile,
                onTap: () => context.pushNamed(AppRoutes.updateProfile.name),
              ),
              ProfileItem(
                icon: Icons.help_outline_rounded,
                title: S.of(context).contactUs,
                onTap: () => context.pushNamed(AppRoutes.help.name),
              ),
              ProfileItem(
                icon: Icons.ios_share,
                title: S.of(context).shareApp,
                onTap: () {
                  shareText(
                    Platform.isAndroid
                        ? AppConfigs.googlePlayUrl
                        : AppConfigs.appleStoreUrl,
                    title: AppConfigs.appName,
                    subject: S.of(context).shareApp,
                  );
                },
              ),
              ProfileItem(
                icon: Icons.info_outline,
                title: S.of(context).aboutApp,
                onTap: () => context.pushNamed(AppRoutes.about.name),
              ),
              ProfileItem(
                icon: Icons.password_rounded,
                title: S.of(context).changePassword,
                onTap: () => context.pushNamed(AppRoutes.changePassword.name),
              ),
              ProfileItem(
                icon: Icons.co_present_rounded,
                title: S.of(context).termsConditions,
                onTap: () => context.pushNamed(AppRoutes.termsConditions.name),
              ),
              ProfileItem(
                icon: Icons.privacy_tip_outlined,
                title: S.of(context).privacyPolicy,
                onTap: () => context.pushNamed(AppRoutes.privacyPolicy.name),
              ),
              const AppDivider(),
              ProfileItem(
                icon: Icons.privacy_tip_outlined,
                title: S.of(context).logout,
                color: AppColors.error600,
                onTap: () async {
                  // final bool? confirmed =
                  await showDialog<bool>(
                    context: context,
                    useRootNavigator: true,
                    builder: (ctx) => MainConfirmDialog(
                      title: S.of(context).confirmLogout,
                      description: S.of(context).areYouSureYouWantToLogout,
                      acceptText: S.of(context).logout,
                      cancelText: S.of(context).cancel,
                      type: AlertDialogType.error,
                      onAccept: () {
                        AppLog.debug('Account logout.');
                        ref.read(authNotifierProvider.notifier).logout();
                      },
                    ),
                  );
                },
              ),
              ProfileItem(
                icon: Icons.person_remove_alt_1_rounded,
                title: S.of(context).deleteAccount,
                color: AppColors.error600,
                onTap: () async {
                  // final bool? confirmed =
                  await showDialog<bool>(
                    context: context,
                    useRootNavigator: true,
                    builder: (ctx) => MainConfirmDialog(
                      title: S.of(context).confirmDeleteAccount,
                      description: S
                          .of(context)
                          .areYouSureYouWantToPermanentlyDeleteYourAccount,
                      acceptText: S.of(context).delete,
                      cancelText: S.of(context).cancel,
                      type: AlertDialogType.error,
                      onAccept: () {
                        AppLog.debug('Account logout.');
                        ref.read(profileServiceProvider).deleteProfile();
                        ref.read(authNotifierProvider.notifier).logout();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
