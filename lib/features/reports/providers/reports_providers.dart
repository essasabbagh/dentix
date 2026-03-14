import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/database/app_database_provider.dart';
import 'package:template/core/database/daos/reports_dao.dart';

// ─── Selected period state ────────────────────────────────────────────────

class ReportPeriod {
  // 1-12
  const ReportPeriod({required this.year, required this.month});
  final int year;
  final int month;

  ReportPeriod copyWith({int? year, int? month}) =>
      ReportPeriod(year: year ?? this.year, month: month ?? this.month);

  String get monthName {
    const names = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return names[month - 1];
  }
}

final reportPeriodProvider = StateProvider<ReportPeriod>((ref) {
  final now = DateTime.now();
  return ReportPeriod(year: now.year, month: now.month);
});

// ─── Monthly summary ──────────────────────────────────────────────────────

class MonthlySummary {
  const MonthlySummary({
    required this.income,
    required this.appointments,
    required this.completedTreatments,
    required this.newPatients,
    required this.totalPatients,
    required this.appointmentsByStatus,
  });
  final double income;
  final int appointments;
  final int completedTreatments;
  final int newPatients;
  final int totalPatients;
  final Map<String, int> appointmentsByStatus;
}

final monthlySummaryProvider = FutureProvider<MonthlySummary>((ref) async {
  final period = ref.watch(reportPeriodProvider);
  final dao = ref.watch(appDatabaseProvider).reportsDao;

  final results = await Future.wait([
    dao.getMonthlyIncome(period.year, period.month),
    dao.getMonthlyAppointmentsCount(period.year, period.month),
    dao.getCompletedTreatmentsCount(year: period.year, month: period.month),
    dao.getNewPatientsCount(period.year, period.month),
    dao.getTotalPatients(),
    dao.getAppointmentStatusBreakdown(period.year, period.month),
  ]);

  return MonthlySummary(
    income: results[0] as double,
    appointments: results[1] as int,
    completedTreatments: results[2] as int,
    newPatients: results[3] as int,
    totalPatients: results[4] as int,
    appointmentsByStatus: results[5] as Map<String, int>,
  );
});

// ─── 12-month income breakdown (bar chart data) ───────────────────────────

final yearlyIncomeBreakdownProvider = FutureProvider<List<MonthlyIncome>>((
  ref,
) async {
  final period = ref.watch(reportPeriodProvider);
  return ref
      .watch(appDatabaseProvider)
      .reportsDao
      .getYearMonthlyBreakdown(period.year);
});

// ─── Top treatment types ──────────────────────────────────────────────────

final topTreatmentTypesProvider = FutureProvider<List<TreatmentTypeStat>>((
  ref,
) async {
  final period = ref.watch(reportPeriodProvider);
  return ref
      .watch(appDatabaseProvider)
      .reportsDao
      .getTopTreatmentTypes(year: period.year, month: period.month);
});

// ─── Yearly income total ──────────────────────────────────────────────────

final yearlyIncomeTotalProvider = FutureProvider<double>((ref) async {
  final period = ref.watch(reportPeriodProvider);
  return ref.watch(appDatabaseProvider).reportsDao.getYearlyIncome(period.year);
});
