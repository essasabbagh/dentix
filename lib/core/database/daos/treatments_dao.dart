import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/treatments_table.dart';
import '../tables/patients_table.dart';

part 'treatments_dao.g.dart';

/// Joined treatment + patient name for global list
class TreatmentWithPatient {
  final TreatmentsTableData treatment;
  final String patientFullName;
  const TreatmentWithPatient(this.treatment, this.patientFullName);
}

@DriftAccessor(tables: [TreatmentsTable, PatientsTable])
class TreatmentsDao extends DatabaseAccessor<AppDatabase>
    with _$TreatmentsDaoMixin {
  TreatmentsDao(super.db);

  /// All treatments joined with patient name, newest first
  Stream<List<TreatmentWithPatient>> watchAllTreatments() {
    final query = select(treatmentsTable).join([
      innerJoin(patientsTable,
          patientsTable.id.equalsExp(treatmentsTable.patientId)),
    ])
      ..orderBy([
        OrderingTerm(
            expression: treatmentsTable.createdAt, mode: OrderingMode.desc)
      ]);
    return query.watch().map((rows) => rows
        .map((r) => TreatmentWithPatient(
              r.readTable(treatmentsTable),
              '${r.readTable(patientsTable).firstName} ${r.readTable(patientsTable).lastName}',
            ))
        .toList());
  }

  Stream<List<TreatmentsTableData>> watchPatientTreatments(int patientId) =>
      (select(treatmentsTable)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm(
                expression: t.createdAt, mode: OrderingMode.desc)]))
          .watch();

  Future<List<TreatmentsTableData>> getAppointmentTreatments(
          int appointmentId) =>
      (select(treatmentsTable)
            ..where((t) => t.appointmentId.equals(appointmentId)))
          .get();

  /// Monthly revenue
  Future<double> getMonthlyRevenue(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final sum = treatmentsTable.price.sum();
    final query = selectOnly(treatmentsTable)
      ..addColumns([sum])
      ..where(treatmentsTable.status.equals('completed') &
          treatmentsTable.createdAt.isBiggerOrEqualValue(start) &
          treatmentsTable.createdAt.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  Future<int> insertTreatment(TreatmentsTableCompanion t) =>
      into(treatmentsTable).insert(t);

  Future<bool> updateTreatment(TreatmentsTableCompanion t) =>
      update(treatmentsTable).replace(t);

  Future<void> completeTreatment(int id) =>
      (update(treatmentsTable)..where((t) => t.id.equals(id))).write(
          TreatmentsTableCompanion(
            status: const Value('completed'),
            updatedAt: Value(DateTime.now()),
          ));

  Future<int> deleteTreatment(int id) =>
      (delete(treatmentsTable)..where((t) => t.id.equals(id))).go();
}
