import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_transitions/go_transitions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/data/storage_service.dart';
import 'package:template/core/constants/keys.dart';
import 'package:template/features/auth/providers/auth_provider.dart';
import 'package:template/features/statics/not_found.dart';
import 'package:template/initialize_app.dart';

import 'app_route_path_cache.dart';
import 'app_routes.dart';
import 'go_router_observer.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Initialize full path cache
  AppRoutePathCache.instance.init(routes);

  // final firebaseAnalyticsObserver = ref.watch(
  //   firebaseAnalyticsObserverProvider,
  // );

  final isAuth = ValueNotifier<AsyncValue<bool>>(const AsyncLoading());
  ref
    ..onDispose(isAuth.dispose)
    // update the listenable, when some provider value changes
    // here, we are just interested in wheter the user's logged in
    ..listen(
      authNotifierProvider.select(
        (AsyncValue<bool> val) => val.whenData((val) => val),
      ),
      (_, AsyncValue<bool> next) {
        isAuth.value = next;
      },
    );

  /// Set default transition values for the entire app.
  GoTransition.defaultCurve = Curves.easeInOut;
  GoTransition.defaultDuration = const Duration(milliseconds: 500);

  final router = GoRouter(
    routes: routes,
    refreshListenable: isAuth,
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    initialLocation: AppRoutes.splash.path,
    errorBuilder: (context, state) => const NotFoundScreen(),
    observers: [
      // Add your navigator observers
      GoRouterObserver(),
      // firebaseAnalyticsObserver,
      GoTransition.observer,
    ],
    // onException: (context, state, router) {
    //   AppLogs.error('GoRouter onException: ${state.error}', 'AppRoutes');
    // },
    redirect: (context, state) {
      // return null;
      final storage = locator<StorageService>();

      final isOnboardingCompleted = storage.readBool(onboardingKey);

      // Extract the current path
      final currentPath = state.uri.path;

      final allowedUnauthPaths = [
        AppRoutes.onboarding.fullPath,
        AppRoutes.login.fullPath,
        AppRoutes.register.fullPath,
        AppRoutes.resetPassword.fullPath,
        AppRoutes.registerConfirm.fullPath,
        AppRoutes.resetPasswordConfirm.fullPath,
        AppRoutes.updatePassword.fullPath,
      ];

      // 1. Show splash screen if auth state is loading or not available
      if (isAuth.value.isLoading || !isAuth.value.hasValue) {
        return AppRoutes.splash.path;
      }

      // 2. Go to onboarding screen if not completed
      if (!isOnboardingCompleted) {
        return AppRoutes.onboarding.path;
      }

      // 3. Authenticated user logic
      if (isAuth.value.requireValue) {
        if (currentPath == AppRoutes.splash.path) {
          return AppRoutes.home.path;
        }
      }

      // 4. Unauthenticated user logic
      if (!isAuth.value.requireValue) {
        // Allow unauthenticated users to access their allowed paths

        if (allowedUnauthPaths.contains(currentPath)) {
          return null; // Stay on the requested path
        }

        // Redirect to login if accessing an invalid path
        return AppRoutes.login.path;
      }

      // 5. Allow navigation to register, reset password, or login if auth false
      if (isAuth.value.requireValue &&
          allowedUnauthPaths.contains(currentPath)) {
        return AppRoutes.home.path;
      }

      // 6. Allow navigation to register, reset password, or login if auth false
      return null;
    },
  );

  ref.onDispose(router.dispose);

  return router;
});

final routeInformationProvider =
    ChangeNotifierProvider<GoRouteInformationProvider>(
      (ref) => ref.watch(routerProvider).routeInformationProvider,
    );
