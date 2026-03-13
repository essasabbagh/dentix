import 'package:flutter/material.dart';

import 'package:template/core/locale/generated/l10n.dart';

final List<NavigationDestination> destinations = [
  NavigationDestination(
    icon: const Icon(Icons.home_outlined),
    selectedIcon: const Icon(Icons.home),
    label: S.current.home,
  ),
  NavigationDestination(
    icon: const Icon(Icons.category_outlined),
    selectedIcon: const Icon(Icons.category),
    label: S.current.category,
  ),
  NavigationDestination(
    icon: const Icon(Icons.search_outlined),
    selectedIcon: const Icon(Icons.search),
    label: S.current.searchScreen,
  ),
  NavigationDestination(
    icon: const Icon(Icons.notifications_outlined),
    selectedIcon: const Icon(Icons.notifications),
    label: S.current.notifications,
  ),
  NavigationDestination(
    icon: const Icon(Icons.person_outline),
    selectedIcon: const Icon(Icons.person),
    label: S.current.myAccount,
  ),
];
