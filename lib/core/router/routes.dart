import 'package:flutter/material.dart';

import 'package:template/core/router/app_routes.dart';
import 'package:template/features/appointments/pages/appointments_page.dart';
import 'package:template/features/dashboard/dashboard_page.dart';
import 'package:template/features/patients/pages/patients_page.dart';
import 'package:template/features/settings/pages/settings_screen.dart';
import 'package:template/features/splash/splash_screen.dart';

final routes = [
  GoRoute(
    path: AppRoutes.splash.path,
    name: AppRoutes.splash.name,
    builder: (context, state) => const SplashPage(),
  ),

  ShellRoute(
    builder: (context, state, child) {
      return MainScaffoldWithNavBar(child: child);
    },
    routes: [
      GoRoute(
        path: AppRoutes.dashboard.path,
        name: AppRoutes.dashboard.name,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.patients.path,
        name: AppRoutes.patients.name,
        builder: (context, state) => const PatientsPage(),
      ),
      GoRoute(
        path: AppRoutes.appointments.path,
        name: AppRoutes.appointments.name,
        builder: (context, state) => const AppointmentsPage(),
      ),
      GoRoute(
        path: AppRoutes.treatments.path,
        name: AppRoutes.treatments.name,
        builder: (context, state) => const TreatmentsPage(),
      ),
      GoRoute(
        path: AppRoutes.payments.path,
        name: AppRoutes.payments.name,
        builder: (context, state) => const PaymentsPage(),
      ),
      GoRoute(
        path: AppRoutes.reports.path,
        name: AppRoutes.reports.name,
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: AppRoutes.settings.path,
        name: AppRoutes.settings.name,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  ),
];

class MainScaffoldWithNavBar extends StatelessWidget {
  const MainScaffoldWithNavBar({
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

            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Patients'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: Text('Appointments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(Icons.medical_services),
                label: Text('Treatments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments),
                label: Text('Payments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
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

// SplashPage
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Payments'));
  }
}

class TreatmentsPage extends StatelessWidget {
  const TreatmentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Treatments'));
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Reports'));
  }
}
