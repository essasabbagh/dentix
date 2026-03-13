import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/patients_table.dart';

part 'patients_dao.g.dart';

@DriftAccessor(tables: [Patients])
class PatientsDao extends DatabaseAccessor<AppDatabase>
    with _$PatientsDaoMixin {
  PatientsDao(super.db);

  Future<List<Patient>> getAllPatients() {
    return select(patients).get();
  }

  Stream<List<Patient>> watchPatients() {
    return select(patients).watch();
  }

  Future<int> insertPatient(PatientsCompanion patient) {
    return into(patients).insert(patient);
  }

  Future deletePatient(int id) {
    return (delete(patients)..where((p) => p.id.equals(id))).go();
  }
}
