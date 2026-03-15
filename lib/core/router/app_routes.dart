import 'app_route_path_cache.dart';

export 'package:go_router/go_router.dart';

enum AppRoutes {
  splash('/', 'splash'),
  root('/root', 'root'),

  dashboard('/dashboard', 'dashboard'),
  patients('/patients', 'patients'),

  patientDetails('/patients/:patientId', 'patientDetails'),

  appointments('/appointments', 'appointments'),
  appointmentDetails('/appointments/:id', 'appointmentDetails'),
  treatments('/treatments', 'treatments'),
  treatmentTemplates('/treatment-templates', 'treatmentTemplates'),
  payments('/payments', 'payments'),
  reports('/reports', 'reports'),
  settings('/settings', 'settings');

  final String path;
  final String name;
  // ignore: sort_constructors_first
  const AppRoutes(this.path, this.name);

  String get fullPath => AppRoutePathCache.instance.getFullPath(this);
}
