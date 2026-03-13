import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/buttons/submit_button.dart';
import 'package:template/core/extensions/extensions.dart';
import 'package:template/core/utils/validators.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/themes/app_colors.dart';

import '../providers/reset_password_provider.dart';

class PasswordResetScreen extends ConsumerWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetPasswordState = ref.watch(resetPasswordProvider);
    final resetPasswordNotifier = ref.read(resetPasswordProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).passwordReset)),

      body: Form(
        key: resetPasswordState.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).enterYourEmailToSendTheVerificationCode,
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  S.of(context).email,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Email Input
              SizedBox(
                height: 65,
                child: TextFormField(
                  autofocus: true,
                  autocorrect: true,
                  enableSuggestions: true,
                  focusNode: resetPasswordState.emailFocusNode,
                  controller: resetPasswordState.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.send,
                  validator: emailValidator,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                  onFieldSubmitted: (_) {
                    resetPasswordNotifier.resetPassword();
                  },
                  decoration: InputDecoration(
                    hintText: S.of(context).enterYourEmail,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              SubmitButton(
                text: S.of(context).sendCode,
                onPressed: resetPasswordNotifier.resetPassword,
                isLoading: resetPasswordNotifier.isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
