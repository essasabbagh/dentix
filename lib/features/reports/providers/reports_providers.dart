import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:dentix/core/database/app_database_provider.dart';
import 'package:dentix/core/database/daos/reports_dao.dart';

// ─── Selected period state (Date Range) ───────────────────────────────────

class ReportPeriod {
  const ReportPeriod({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  ReportPeriod copyWith({DateTime? start, DateTime? end}) =>
      ReportPeriod(start: start ?? this.start, end: end ?? this.end);

  String get label {
    // Simple label: "Month Year" if within same month, else "Start - End"
    if (start.year == end.year && start.month == end.month) {
      return '${_monthName(start.month)} ${start.year}';
    }
    return '${start.year}/${start.month}/${start.day} - ${end.year}/${end.month}/${end.day}';
  }

  static String _monthName(int month) {
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
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1);
  return ReportPeriod(start: start, end: end);
});

// ─── Summary ──────────────────────────────────────────────────────────────

class ReportSummary {
  const ReportSummary({
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

final monthlySummaryProvider = FutureProvider<ReportSummary>((ref) async {
  final period = ref.watch(reportPeriodProvider);
  final dao = ref.watch(appDatabaseProvider).reportsDao;

  final results = await Future.wait([
    dao.getIncomeInRange(period.start, period.end),
    dao.getAppointmentsCountInRange(period.start, period.end),
    dao.getCompletedTreatmentsCountInRange(period.start, period.end),
    dao.getNewPatientsCountInRange(period.start, period.end),
    dao.getTotalPatients(),
    dao.getAppointmentStatusBreakdownInRange(period.start, period.end),
  ]);

  return ReportSummary(
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
  // We still show breakdown by year based on the start date's year
  return ref
      .watch(appDatabaseProvider)
      .reportsDao
      .getYearMonthlyBreakdown(period.start.year);
});

// ─── Top treatment types ──────────────────────────────────────────────────

final topTreatmentTypesProvider = FutureProvider<List<TreatmentTypeStat>>((
  ref,
) async {
  final period = ref.watch(reportPeriodProvider);
  return ref
      .watch(appDatabaseProvider)
      .reportsDao
      .getTopTreatmentTypesInRange(period.start, period.end);
});

// ─── Yearly income total ──────────────────────────────────────────────────

final yearlyIncomeTotalProvider = FutureProvider<double>((ref) async {
  final period = ref.watch(reportPeriodProvider);
  return ref
      .watch(appDatabaseProvider)
      .reportsDao
      .getYearlyIncome(period.start.year);
});
