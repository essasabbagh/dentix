// import 'package:go_router/go_router.dart';

import 'package:dentix/core/router/app_routes.dart';

class AppRoutePathCache {
  AppRoutePathCache._();
  static final AppRoutePathCache instance = AppRoutePathCache._();

  final Map<String, String> _nameToPath = {};

  void init(List<RouteBase> routes) {
    _nameToPath.clear();

    void extract(RouteBase route, String basePath) {
      if (route is GoRoute) {
        final fullPath = Uri.parse(
          '$basePath/${route.path}',
        ).normalizePath().toString().replaceAll(RegExp(r'/{2,}'), '/');

        if (route.name != null) {
          _nameToPath[route.name!] = fullPath;
        }

        for (final subRoute in route.routes) {
          extract(subRoute, fullPath);
        }
      } else if (route is ShellRoute) {
        for (final subRoute in route.routes) {
          extract(subRoute, basePath);
        }
      }
    }

    for (final route in routes) {
      extract(route, '');
    }
  }

  String getFullPath(AppRoutes route) {
    final path = _nameToPath[route.name];
    if (path == null) {
      throw Exception(
        'Full path for ${route.name} not found. Did you forget to call init()?',
      );
    }
    return path;
  }
}
