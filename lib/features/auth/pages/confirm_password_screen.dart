// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/buttons/submit_button.dart';
import 'package:template/core/extensions/extensions.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/features/auth/widgets/pin_code_widget.dart';

import '../providers/confirm_password_provider.dart';

class ConfirmPasswordScreen extends ConsumerWidget {
  const ConfirmPasswordScreen({super.key, required this.email});

  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(confirmPasswordProvider(email));
    final notifier = ref.read(confirmPasswordProvider(email).notifier);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).passwordReset)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).emailConfirmation,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).weHaveSentACodeToYourEmail,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              email ?? '-',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            PinCodeWidget(
              controller: state.codeController,
              focusNode: state.codeFocusNode,
              onCompleted: (val) {
                notifier.confirmCode();
              },
            ),

            const SizedBox(height: 16),
            Text(
              state.errorText ?? '',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                color: AppColors.error600,
              ),
            ),

            const SizedBox(height: 24),
            // Submit Button
            SubmitButton(
              text: S.of(context).confirm,
              onPressed: notifier.confirmCode,
              isLoading: notifier.isLoading,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
