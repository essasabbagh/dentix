import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/buttons/submit_button.dart';
import 'package:template/components/form/password_strength_checker.dart';
import 'package:template/components/main/logo.dart';
import 'package:template/configs/app_configs.dart';
import 'package:template/core/utils/validators.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/router/app_routes.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/core/utils/url_luncher.dart';
import 'package:template/features/settings/widgets/locale_menu.dart';

import '../providers/register_provider.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final registerState = ref.watch(registerProvider);
    final registerNotifier = ref.read(registerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).signUp),
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),

            child: const LocaleDropdown(),
          ),
        ],
      ),
      body: Form(
        key: registerState.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Logo(width: 150),
              const SizedBox(height: 24),

              // name input
              Row(
                spacing: 18,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // first name
                  Expanded(
                    child: Column(
                      spacing: 10,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            S.of(context).firstName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                          ),
                        ),
                        SizedBox(
                          height: 65,
                          child: TextFormField(
                            autofocus: true,
                            autocorrect: true,
                            enableSuggestions: true,
                            focusNode: registerState.firstNameFocusNode,
                            controller: registerState.firstNameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: userNameValidator,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus!.unfocus();
                            },
                            onFieldSubmitted: (_) =>
                                registerState.lastNameFocusNode.requestFocus(),
                            decoration: InputDecoration(
                              hintText: S.of(context).enterYourFirstName,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // last name
                  Expanded(
                    child: Column(
                      spacing: 10,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            S.of(context).lastName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                          ),
                        ),
                        SizedBox(
                          height: 65,
                          child: TextFormField(
                            autofocus: true,
                            autocorrect: true,
                            enableSuggestions: true,
                            focusNode: registerState.lastNameFocusNode,
                            controller: registerState.lastNameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: userNameValidator,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus!.unfocus();
                            },
                            onFieldSubmitted: (_) =>
                                registerState.emailFocusNode.requestFocus(),
                            decoration: InputDecoration(
                              hintText: S.of(context).enterYourLastName,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  S.of(context).email,
                  style: textTheme.bodyMedium?.copyWith(
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
                  focusNode: registerState.emailFocusNode,
                  controller: registerState.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: emailValidator,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                  onFieldSubmitted: (_) =>
                      registerState.passwordFocusNode.requestFocus(),
                  decoration: InputDecoration(
                    hintText: S.of(context).enterYourEmail,
                    // labelText: 'Email',
                    // prefixIcon: const Icon(Icons.email),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
              // Password Input
              SizedBox(
                height: 65,
                child: TextFormField(
                  controller: registerState.passwordController,
                  focusNode: registerState.passwordFocusNode,
                  textInputAction: TextInputAction.next,
                  obscureText: !registerState.isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: registerNotifier.onPasswordChanged,
                  validator: passwordValidator,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                  onFieldSubmitted: (_) =>
                      registerState.confirmPasswordFocusNode.requestFocus(),
                  decoration: InputDecoration(
                    hintText: S.of(context).enterYourPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        registerState.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: registerNotifier.togglePasswordVisibility,
                    ),
                  ),
                ),
              ),
              // Password Input
              PasswordStrengthChecker(
                password: registerState.passwordController.text,
              ),
              const SizedBox(height: 16),
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
                  controller: registerState.confirmPasswordController,
                  focusNode: registerState.confirmPasswordFocusNode,
                  textInputAction: TextInputAction.send,
                  obscureText: !registerState.isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (val) => confirmPasswordValidator(
                    val,
                    registerState.passwordController.text,
                  ),
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                  onFieldSubmitted: (_) => registerNotifier.register(),
                  decoration: InputDecoration(
                    hintText: S.of(context).enterYourPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        registerState.isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed:
                          registerNotifier.toggleConfirmPasswordVisibility,
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 16),
              // Terms and Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.scale(
                    scale: 1.4,
                    child: Checkbox(
                      splashRadius: 16,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      checkColor: AppColors.white,
                      activeColor: AppColors.secondaryColor,
                      value: registerState.isChecked,
                      onChanged: registerNotifier.toggleTermsAndConditions,
                      side: const BorderSide(
                        // color: AppColors.azureBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      style: const TextStyle(fontSize: 14, height: 1.8),
                      TextSpan(
                        children: [
                          TextSpan(
                            text: S.of(context).byRegisteringYouAgreeToOur,
                          ),
                          TextSpan(
                            text: S.of(context).termsOfService,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  openUrl(AppConfigs.termsOfServiceUrl),
                          ),
                          TextSpan(text: S.of(context).and),
                          TextSpan(
                            text: S.of(context).privacyPolicy,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  openUrl(AppConfigs.privacyPolicyUrl),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Social Media Login Buttons
              const SizedBox(height: 16),
              // Submit Button
              SubmitButton(
                text: S.of(context).register,
                onPressed: registerNotifier.register,
                isLoading: registerNotifier.isLoading,
              ),
              const SizedBox(height: 22),
              Text.rich(
                style: const TextStyle(fontSize: 14, height: 1.8),
                TextSpan(
                  children: [
                    TextSpan(text: S.of(context).doYouHaveAnAccount),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: S.of(context).signIn,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryColor,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // ref.invalidate(authNotifierProvider);
                          context.goNamed(AppRoutes.login.name);
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Center(
              //   child: TextButton(
              //     onPressed: () {
              //       ref.invalidate(authNotifierProvider);
              //       context.goNamed(AppRoutes.login.name);
              //     },
              //     child: Text(S.of(context).doYouHaveAnAccount),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
