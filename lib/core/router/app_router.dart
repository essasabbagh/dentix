import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_transitions/go_transitions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/constants/keys.dart';
import 'package:template/features/statics/not_found.dart';

import 'app_route_path_cache.dart';
import 'app_routes.dart';
import 'go_router_observer.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  /// Initialize route full path cache
  AppRoutePathCache.instance.init(routes);

  /// Global transition configuration
  GoTransition.defaultCurve = Curves.easeInOut;
  GoTransition.defaultDuration = const Duration(milliseconds: 400);

  final router = GoRouter(
    routes: routes,

    /// Root navigator key
    navigatorKey: rootNavigatorKey,

    /// Initial screen
    initialLocation: AppRoutes.dashboard.path,

    /// Debug logs
    debugLogDiagnostics: false,

    /// Error screen
    errorBuilder: (context, state) => const NotFoundScreen(),

    /// Observers
    observers: [
      GoRouterObserver(),
      GoTransition.observer,
    ],

    /// No redirect logic
    redirect: (context, state) {
      return null;
    },
  );

  ref.onDispose(router.dispose);

  return router;
});
