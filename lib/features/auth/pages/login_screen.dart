import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/buttons/submit_button.dart';
import 'package:template/components/main/logo.dart';
import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/router/app_routes.dart';
import 'package:template/core/themes/app_colors.dart';
import 'package:template/core/utils/validators.dart';
import 'package:template/features/auth/widgets/or_divider_widget.dart';
import 'package:template/features/settings/widgets/locale_menu.dart';

import '../providers/login_provider.dart';
import '../services/social_login.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).signIn),
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
        key: loginState.loginFormKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          child: AutofillGroup(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Logo(width: 150),
                const SizedBox(height: 24),
                Text(
                  S.of(context).signIn,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).signInWithYourEmail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    S.of(context).email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    autocorrect: false,
                    enableSuggestions: false,
                    focusNode: loginState.emailFocusNode,
                    controller: loginState.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: emailValidator,
                    autofillHints: const [AutofillHints.email],
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    onFieldSubmitted: (_) =>
                        loginState.passwordFocusNode.requestFocus(),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    autocorrect: false,
                    enableSuggestions: false,
                    controller: loginState.passwordController,
                    focusNode: loginState.passwordFocusNode,
                    textInputAction: TextInputAction.send,
                    obscureText: !loginState.isPasswordVisible,
                    keyboardType: TextInputType.visiblePassword,
                    validator: passwordLoginValidator,
                    autofillHints: const [AutofillHints.password],
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    onFieldSubmitted: (_) => loginNotifier.login(),
                    decoration: InputDecoration(
                      hintText: S.of(context).enterYourPassword,
                      // labelText: 'Password',
                      // prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          loginState.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: loginNotifier.togglePasswordVisibility,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () =>
                        context.goNamed(AppRoutes.resetPassword.name),
                    child: Text(
                      S.of(context).didForgetYourPassword,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Submit Button
                SubmitButton(
                  text: S.of(context).login,
                  onPressed: loginNotifier.login,
                  isLoading: loginNotifier.isLoading,
                ),
                const SizedBox(height: 32),

                if (Platform.isAndroid)
                  Column(
                    children: [
                      OrDivider(text: S.of(context).orSignInWith),
                      const SizedBox(height: 16),
                      const Center(child: GoogleLoginWidget()),
                      const SizedBox(height: 32),
                    ],
                  ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: S.of(context).dontHaveAnAccount,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: S.of(context).signUp,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              context.goNamed(AppRoutes.register.name),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
