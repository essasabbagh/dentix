// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/buttons/submit_button.dart';
import 'package:template/core/constants/images.dart';
import 'package:template/core/extensions/extensions.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/themes/app_colors.dart';

import '../providers/register_confirm_provider.dart';
import '../widgets/pin_code_widget.dart';

class RegisterConfirmScreen extends ConsumerWidget {
  const RegisterConfirmScreen({super.key, required this.email});

  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final state = ref.watch(registerConfirmNotifier);
    final notifier = ref.read(registerConfirmNotifier.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).passwordReset)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.imagesLogo, width: 150),
            const SizedBox(height: 24),
            Text(S.of(context).confirmEmail, style: textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(
              S.of(context).weHaveSentACodeToYourEmail,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              email ?? '-',
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // pin
            Directionality(
              textDirection: TextDirection.ltr,
              child: PinCodeWidget(
                controller: state.codeController,
                focusNode: state.codeFocusNode,
                onCompleted: (val) {
                  if (!email.isEmptyOrNull) {
                    notifier.verifyEmail(email!);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.errorText ?? '',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                color: AppColors.error600,
              ),
            ),

            const SizedBox(height: 24),
            Text.rich(
              style: const TextStyle(fontSize: 14, height: 1.8),
              TextSpan(
                children: [
                  TextSpan(
                    text: S.of(context).resendCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        notifier.codeController.clear();
                        notifier.codeFocusNode.requestFocus();
                      },
                  ),
                  // const TextSpan(text: ' '),
                  // TextSpan(text: S.of(context).within_30_seconds),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SubmitButton(
              text: S.of(context).submit,
              isLoading: notifier.isLoading,
              onPressed: () {
                if (!email.isEmptyOrNull) {
                  notifier.verifyEmail(email!);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
