import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/extensions/context_ext.dart';
import 'package:template/core/router/app_router.dart';
import 'package:template/core/router/app_routes.dart';
import 'package:template/core/router/go_router_extension.dart';
import 'package:template/core/themes/app_colors.dart';

import 'constants/destinations.dart';

class RootScreen extends ConsumerWidget {
  const RootScreen({super.key, required this.child});

  final Widget child;

  // Ordered list of shell tabs
  static const List<AppRoutes> _tabs = [
    AppRoutes.home,
    AppRoutes.category,
    AppRoutes.search,
    AppRoutes.notifications,
    AppRoutes.profile,
  ];

  static const List<AppRoutes> _hideNavBarRoutes = [
    // Add routes where you want to hide the nav bar
    AppRoutes.search,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final location = ref.watch(routerProvider).location;

    // Derive the selected index directly from the current location
    final selectedIndex = _tabs
        .indexWhere(
          (route) => location.startsWith(route.path),
        )
        .clamp(0, _tabs.length - 1); // fallback to 0 (home) if no match

    final showNavBar = !_hideNavBarRoutes.any(
      (route) => location.startsWith(route.path.split('/:').first),
    );

    // void onDestinationSelected(int index) {
    //   // go() resets the stack — back will have nothing to pop inside the shell
    //   ref.read(routerProvider).go(_tabs[index].path);
    // }

    void onDestinationSelected(int index) {
      final router = ref.read(routerProvider);
      final targetPath = _tabs[index].path;

      if (index == 0) {
        // Going to home — always reset the stack
        router.go(targetPath);
      } else {
        // Going to another tab — push so back returns to home
        router.push(targetPath);
      }
    }

    return PopScope(
      // When the user presses back and we're NOT on home, go to home.
      // When we ARE on home, let the system handle it (exit / do nothing).
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(routerProvider).go(AppRoutes.home.path);
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: showNavBar
            ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                child: NavigationBar(
                  elevation: 0,
                  shadowColor: theme.shadowColor,
                  indicatorColor: theme.primaryColor,
                  surfaceTintColor: theme.unselectedWidgetColor,
                  backgroundColor: context.isDark
                      ? AppColors.primary900
                      : AppColors.primary50,
                  animationDuration: Durations.medium1,
                  indicatorShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  selectedIndex: selectedIndex,
                  destinations: destinations,
                  onDestinationSelected: onDestinationSelected,
                ),
              )
            : null,
      ),
    );
  }
}
