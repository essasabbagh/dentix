import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/payments_table.dart';
import '../tables/treatments_table.dart';
import '../tables/appointments_table.dart';
import '../tables/patients_table.dart';

part 'reports_dao.g.dart';

class MonthlyIncome {
  const MonthlyIncome(this.year, this.month, this.total);
  final int year;
  final int month;
  final double total;
}

class TreatmentTypeStat {
  const TreatmentTypeStat(this.treatmentType, this.count, this.revenue);
  final String treatmentType;
  final int count;
  final double revenue;
}

@DriftAccessor(
  tables: [PaymentsTable, TreatmentsTable, AppointmentsTable, PatientsTable],
)
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  ReportsDao(super.db);

  // ─── Income ────────────────────────────────────────────────

  /// Total paid income for a given month
  Future<double> getMonthlyIncome(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final sum = paymentsTable.amount.sum();
    final q = selectOnly(paymentsTable)
      ..addColumns([sum])
      ..where(
        paymentsTable.paymentStatus.equals('paid') &
            paymentsTable.paymentDate.isBiggerOrEqualValue(start) &
            paymentsTable.paymentDate.isSmallerThanValue(end),
      );
    final result = await q.getSingle();
    return result.read(sum) ?? 0.0;
  }

  /// Total paid income for a given year
  Future<double> getYearlyIncome(int year) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    final sum = paymentsTable.amount.sum();
    final q = selectOnly(paymentsTable)
      ..addColumns([sum])
      ..where(
        paymentsTable.paymentStatus.equals('paid') &
            paymentsTable.paymentDate.isBiggerOrEqualValue(start) &
            paymentsTable.paymentDate.isSmallerThanValue(end),
      );
    final result = await q.getSingle();
    return result.read(sum) ?? 0.0;
  }

  /// Monthly income for each month of a given year (for chart)
  Future<List<MonthlyIncome>> getYearMonthlyBreakdown(int year) async {
    final results = <MonthlyIncome>[];
    for (int m = 1; m <= 12; m++) {
      final amount = await getMonthlyIncome(year, m);
      results.add(MonthlyIncome(year, m, amount));
    }
    return results;
  }

  // ─── Treatments ─────────────────────────────────────────────

  /// Count + revenue grouped by treatment type (top types)
  Future<List<TreatmentTypeStat>> getTopTreatmentTypes({
    int limit = 8,
    int? year,
    int? month,
  }) async {
    // Raw SQL via customSelect for GROUP BY
    String where = "status = 'completed'";
    if (year != null && month != null) {
      final start = DateTime(year, month, 1).toIso8601String().substring(0, 10);
      final end = DateTime(
        year,
        month + 1,
        1,
      ).toIso8601String().substring(0, 10);
      where += " AND created_at >= '$start' AND created_at < '$end'";
    } else if (year != null) {
      final start = DateTime(year, 1, 1).toIso8601String().substring(0, 10);
      final end = DateTime(year + 1, 1, 1).toIso8601String().substring(0, 10);
      where += " AND created_at >= '$start' AND created_at < '$end'";
    }

    final rows = await customSelect(
      '''
      SELECT treatment_type,
             COUNT(*) AS cnt,
             SUM(price) AS rev
      FROM treatments
      WHERE $where
      GROUP BY treatment_type
      ORDER BY cnt DESC
      LIMIT $limit
      ''',
      readsFrom: {treatmentsTable},
    ).get();

    return rows
        .map(
          (r) => TreatmentTypeStat(
            r.read<String>('treatment_type'),
            r.read<int>('cnt'),
            r.read<double>('rev'),
          ),
        )
        .toList();
  }

  /// Total completed treatments count
  Future<int> getCompletedTreatmentsCount({int? year, int? month}) async {
    final count = treatmentsTable.id.count();
    final q = selectOnly(treatmentsTable)
      ..addColumns([count])
      ..where(treatmentsTable.status.equals('completed'));

    if (year != null && month != null) {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 1);
      q.where(
        treatmentsTable.createdAt.isBiggerOrEqualValue(start) &
            treatmentsTable.createdAt.isSmallerThanValue(end),
      );
    } else if (year != null) {
      final start = DateTime(year, 1, 1);
      final end = DateTime(year + 1, 1, 1);
      q.where(
        treatmentsTable.createdAt.isBiggerOrEqualValue(start) &
            treatmentsTable.createdAt.isSmallerThanValue(end),
      );
    }

    return (await q.getSingle()).read(count) ?? 0;
  }

  // ─── Appointments ───────────────────────────────────────────

  /// Appointment counts by status for a given month
  Future<Map<String, int>> getAppointmentStatusBreakdown(
    int year,
    int month,
  ) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final rows = await customSelect(
      '''
      SELECT status, COUNT(*) AS cnt
      FROM appointments
      WHERE appointment_date >= ? AND appointment_date < ?
      GROUP BY status
      ''',
      variables: [
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
      readsFrom: {appointmentsTable},
    ).get();

    return {for (final r in rows) r.read<String>('status'): r.read<int>('cnt')};
  }

  /// Total appointments in a month
  Future<int> getMonthlyAppointmentsCount(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final count = appointmentsTable.id.count();
    final q = selectOnly(appointmentsTable)
      ..addColumns([count])
      ..where(
        appointmentsTable.appointmentDate.isBiggerOrEqualValue(start) &
            appointmentsTable.appointmentDate.isSmallerThanValue(end),
      );
    return (await q.getSingle()).read(count) ?? 0;
  }

  // ─── Patients ───────────────────────────────────────────────

  /// New patients registered this month
  Future<int> getNewPatientsCount(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final count = patientsTable.id.count();
    final q = selectOnly(patientsTable)
      ..addColumns([count])
      ..where(
        patientsTable.createdAt.isBiggerOrEqualValue(start) &
            patientsTable.createdAt.isSmallerThanValue(end),
      );
    return (await q.getSingle()).read(count) ?? 0;
  }

  /// Total patients ever
  Future<int> getTotalPatients() async {
    final count = patientsTable.id.count();
    final q = selectOnly(patientsTable)..addColumns([count]);
    return (await q.getSingle()).read(count) ?? 0;
  }
}
