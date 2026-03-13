import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/buttons/submit_button.dart';
import 'package:template/components/form/password_strength_checker.dart';
import 'package:template/core/utils/validators.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/themes/app_colors.dart';

import '../helpers/reset_helper.dart';
import '../providers/update_password_provider.dart';

class UpdatePasswordScreen extends ConsumerWidget {
  const UpdatePasswordScreen({
    super.key,
    required this.email,
    required this.resetCode,
  });

  final String email;
  final String resetCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final ResetHelper rest = ResetHelper(email: email, resetCode: resetCode);

    final state = ref.watch(updatePasswordProvider(rest.encode()));
    final notifier = ref.read(updatePasswordProvider(rest.encode()).notifier);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).passwordReset)),
      body: Form(
        key: state.updatePasswordFormKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(S.of(context).passwordReset, style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(
                S.of(context).yourNewPasswordMustBeDifferentFromThePasswordYou,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // new pass
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  S.of(context).password,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 65,
                child: TextFormField(
                  controller: state.passwordController,
                  focusNode: state.passwordFocusNode,
                  textInputAction: TextInputAction.next,
                  obscureText: !state.isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: notifier.onPasswordChanged,
                  validator: passwordValidator,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                  onFieldSubmitted: (_) =>
                      state.confirmPasswordFocusNode.requestFocus(),
                  decoration: InputDecoration(
                    hintText: S.of(context).enterYourPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: notifier.togglePasswordVisibility,
                    ),
                  ),
                ),
              ),
              // Password checker
              PasswordStrengthChecker(password: state.passwordController.text),
              const SizedBox(height: 16),

              // confirm pass
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  S.of(context).confirmPassword,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 65,
                child: TextFormField(
                  controller: state.confirmPasswordController,
                  focusNode: state.confirmPasswordFocusNode,
                  textInputAction: TextInputAction.send,
                  obscureText: !state.isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (val) => confirmPasswordValidator(
                    val,
                    state.passwordController.text,
                  ),
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                  onFieldSubmitted: (_) => notifier.updatePassword(),
                  decoration: InputDecoration(
                    hintText: S.of(context).enterYourPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: notifier.toggleConfirmPasswordVisibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SubmitButton(
                text: S.of(context).save,
                onPressed: notifier.updatePassword,
                isLoading: notifier.isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
