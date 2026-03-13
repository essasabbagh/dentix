import 'dart:async';

import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/form/social_icon_button.dart';
import 'package:template/core/constants/images.dart';
import 'package:template/core/utils/app_log.dart';
import 'package:template/core/utils/snackbars.dart';

import '../providers/social_login_provider.dart';

/// To run this example, replace this value with your client ID, and/or
/// update the relevant configuration files, as described in the README.
String? clientId;

/// To run this example, replace this value with your server client ID, and/or
/// update the relevant configuration files, as described in the README.
String? serverClientId;

/// The scopes required by this application.
const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/contacts.readonly',
];

class GoogleLoginWidget extends ConsumerStatefulWidget {
  const GoogleLoginWidget({super.key});

  @override
  ConsumerState createState() => _GoogleLoginWidgetState();
}

class _GoogleLoginWidgetState extends ConsumerState<GoogleLoginWidget> {
  @override
  void initState() {
    super.initState();

    final GoogleSignIn signIn = GoogleSignIn.instance;

    unawaited(
      signIn
          .initialize(clientId: clientId, serverClientId: serverClientId)
          .then((_) {
            signIn.authenticationEvents
                .listen(_handleAuthenticationEvent)
                .onError(_handleAuthenticationError);

            /// This example always uses the stream-based approach to
            ///  determining which UI state to show,
            ///  rather than using the future returned here,
            /// if any, to conditionally skip directly to the signed-in state.
            signIn.attemptLightweightAuthentication();
          }),
    );
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    // Check for existing authorization.
    final GoogleSignInClientAuthorization? authorization = await user
        ?.authorizationClient
        .authorizationForScopes(scopes);

    AppLog.info('user: $user');
    AppLog.info('idToken: ${user?.authentication.idToken}');

    try {
      if (user != null && user.authentication.idToken != null) {
        AppLog.info('accessToken: ${authorization?.accessToken}');
        AppLog.success('idToken: ${user.authentication.idToken}');
        AppLog.success('email: ${user.email}');
        AppLog.success('photoUrl: ${user.photoUrl}');
        AppLog.success('id: ${user.id}');
        AppLog.success('displayName: ${user.displayName}');
        await ref
            .read(socialLoginProvider)
            .socialLogin(
              user.authentication.idToken ?? '',
              authorization?.accessToken ?? '',
            );
      }
    } on GoogleSignInException catch (e) {
      final errorMessage = _errorMessageFromSignInException(e);
      AppSnackBar.error(errorMessage);
    } catch (e) {
      AppSnackBar.error(e.toString());
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    AppLog.error(
      e is GoogleSignInException
          ? _errorMessageFromSignInException(e)
          : 'Unknown error: $e',
    );
  }

  // Future<void> _handleSignOut() async {
  //   // Disconnect instead of just signing out, to reset the example state as
  //   // much as possible.
  //   await GoogleSignIn.instance.disconnect();
  // }

  @override
  Widget build(BuildContext context) {
    if (GoogleSignIn.instance.supportsAuthenticate()) {
      return SocialIconButton(
        iconPath: AppImages.iconsGoogleIcon,
        onPressed: () async {
          try {
            final GoogleSignInAccount res = await GoogleSignIn.instance
                .authenticate(scopeHint: ['email', 'profile']);

            if (res.authentication.idToken != null) {
              AppLog.success('idToken: ${res.authentication.idToken}');
              AppLog.success('email: ${res.email}');
              AppLog.success('photoUrl: ${res.photoUrl}');
              AppLog.success('id: ${res.id}');
              AppLog.success('displayName: ${res.displayName}');
              // accessToken
            }

            await ref
                .read(socialLoginProvider)
                .socialLogin(res.authentication.idToken ?? '', '');
          } on GoogleSignInException catch (e) {
            final errorMessage = _errorMessageFromSignInException(e);
            AppSnackBar.error(errorMessage);
          } catch (e) {
            AppSnackBar.error(e.toString());
          }
        },
      );
    }

    return const SizedBox();
  }

  String _errorMessageFromSignInException(GoogleSignInException e) {
    // In practice, an application should likely have specific handling for most
    // or all of the, but for simplicity this just handles cancel, and reports
    // the rest as generic errors.
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in canceled',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
  }
}
