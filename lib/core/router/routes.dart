import 'package:flutter/material.dart';

import 'package:template/core/router/app_routes.dart';
import 'package:template/features/appointments/pages/appointment_details_page.dart';
import 'package:template/features/appointments/pages/appointments_page.dart';
import 'package:template/features/dashboard/dashboard_page.dart';
import 'package:template/features/patients/pages/patient_detail_page.dart';
import 'package:template/features/patients/pages/patients_page.dart';
import 'package:template/features/payments/pages/payments_page.dart';
import 'package:template/features/reports/pages/reports_page.dart';
import 'package:template/features/root/root_page.dart';
import 'package:template/features/settings/pages/settings_screen.dart';
import 'package:template/features/splash/splash_screen.dart';
import 'package:template/features/treatments/pages/treatment_templates_page.dart';
import 'package:template/features/treatments/pages/treatments_page.dart';

final routes = [
  GoRoute(
    path: AppRoutes.splash.path,
    name: AppRoutes.splash.name,
    builder: (context, state) => const SplashPage(),
  ),

  ShellRoute(
    builder: (context, state, child) {
      return RootPage(child: child);
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
        routes: [
          GoRoute(
            path: AppRoutes.patientDetails.path,
            name: AppRoutes.patientDetails.name,
            builder: (context, state) {
              final patientId = state.pathParameters['patientId'] ?? '0';
              final patientIdInt = int.parse(patientId);

              return PatientDetailPage(patientId: patientIdInt);
            },
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.appointments.path,
        name: AppRoutes.appointments.name,
        builder: (context, state) => const AppointmentsPage(),
        routes: [
          GoRoute(
            path: AppRoutes.appointmentDetails.path,
            name: AppRoutes.appointmentDetails.name,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '0';
              return AppointmentDetailsPage(id: int.parse(id));
            },
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.treatments.path,
        name: AppRoutes.treatments.name,
        builder: (context, state) => const TreatmentsPage(),
      ),
      GoRoute(
        path: AppRoutes.treatmentTemplates.path,
        name: AppRoutes.treatmentTemplates.name,
        builder: (context, state) => const TreatmentTemplatesPage(),
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
        builder: (context, state) => const SettingsScreen(),
        // builder: (context, state) => const SettingsPage(),
      ),
    ],
  ),
];

// SplashPage
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
