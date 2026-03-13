import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/patients_table.dart';

part 'patients_dao.g.dart';

@DriftAccessor(tables: [PatientsTable])
class PatientsDao extends DatabaseAccessor<AppDatabase>
    with _$PatientsDaoMixin {
  PatientsDao(super.db);

  // ─── Queries ───────────────────────────────────────────────

  /// All patients ordered by last name
  Future<List<PatientsTableData>> getAllPatients() => (select(
    patientsTable,
  )..orderBy([(t) => OrderingTerm(expression: t.lastName)])).get();

  /// Reactive stream of all patients
  Stream<List<PatientsTableData>> watchAllPatients() => (select(
    patientsTable,
  )..orderBy([(t) => OrderingTerm(expression: t.lastName)])).watch();

  /// Search patients by name or phone
  Future<List<PatientsTableData>> searchPatients(String query) {
    final q = '%$query%';
    return (select(patientsTable)..where(
          (t) => t.firstName.like(q) | t.lastName.like(q) | t.phone.like(q),
        ))
        .get();
  }

  Stream<List<PatientsTableData>> watchSearchPatients(String query) {
    final q = '%$query%';
    return (select(patientsTable)
          ..where(
            (t) => t.firstName.like(q) | t.lastName.like(q) | t.phone.like(q),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.lastName)]))
        .watch();
  }

  /// Get patient by id
  Future<PatientsTableData?> getPatientById(int id) =>
      (select(patientsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<PatientsTableData?> watchPatientById(int id) => (select(
    patientsTable,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Total patient count
  Future<int> getPatientsCount() async {
    final count = patientsTable.id.count();
    final query = selectOnly(patientsTable)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ─── Mutations ─────────────────────────────────────────────

  Future<int> insertPatient(PatientsTableCompanion patient) =>
      into(patientsTable).insert(patient);

  Future<bool> updatePatient(PatientsTableCompanion patient) =>
      update(patientsTable).replace(patient);

  Future<int> deletePatient(int id) =>
      (delete(patientsTable)..where((t) => t.id.equals(id))).go();
}
