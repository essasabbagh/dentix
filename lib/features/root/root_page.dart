import 'package:flutter/material.dart';

import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/router/app_routes.dart';

class RootPage extends StatelessWidget {
  const RootPage({
    super.key,
    required this.child,
  });

  final Widget child;

  static const List<AppRoutes> navRoutes = [
    AppRoutes.dashboard,
    AppRoutes.patients,
    AppRoutes.appointments,
    AppRoutes.treatments,
    AppRoutes.payments,
    AppRoutes.reports,
    AppRoutes.odontogram,
    AppRoutes.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 220,

            leading: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'DentixFlow',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            selectedIndex: selectedIndex,

            onDestinationSelected: (index) {
              context.goNamed(navRoutes[index].name);
            },

            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(
                  Icons.dashboard,
                  color: Colors.white,
                ),
                label: Text(S.of(context).dashboard),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.people_outline),
                selectedIcon: const Icon(
                  Icons.people,
                  color: Colors.white,
                ),
                label: Text(S.of(context).patients),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                ),
                label: Text(S.of(context).appointments),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.medical_services_outlined),
                selectedIcon: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                ),
                label: Text(S.of(context).treatments),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.payments_outlined),
                selectedIcon: const Icon(
                  Icons.payments,
                  color: Colors.white,
                ),
                label: Text(S.of(context).payments),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                ),
                label: Text(S.of(context).reports),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.face_outlined),
                selectedIcon: Icon(
                  Icons.face_6,
                  color: Colors.white,
                ),
                label: Text('Odontogram'),
              ),

              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                label: Text(S.of(context).settings),
              ),
            ],
          ),

          const VerticalDivider(width: 1),

          Expanded(child: child),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    for (int i = 0; i < navRoutes.length; i++) {
      if (location.startsWith(navRoutes[i].path)) {
        return i;
      }
    }

    return 0;
  }
}
