import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../models/patient_model.dart';

/// Repository mediates between PatientsService and PatientsDao
class PatientsRepository {
  final AppDatabase _db;

  PatientsRepository(this._db);

  // ─── Mappers ───────────────────────────────────────────────

  PatientModel _fromData(PatientsTableData d) => PatientModel(
        id: d.id,
        firstName: d.firstName,
        lastName: d.lastName,
        phone: d.phone,
        email: d.email,
        gender: d.gender,
        birthDate: d.birthDate,
        address: d.address,
        notes: d.notes,
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
      );

  PatientsTableCompanion _toCompanion(PatientModel m) =>
      PatientsTableCompanion(
        id: Value(m.id),
        firstName: Value(m.firstName),
        lastName: Value(m.lastName),
        phone: Value(m.phone),
        email: Value(m.email),
        gender: Value(m.gender),
        birthDate: Value(m.birthDate),
        address: Value(m.address),
        notes: Value(m.notes),
        updatedAt: Value(DateTime.now()),
      );

  // ─── Read ──────────────────────────────────────────────────

  Future<List<PatientModel>> getAllPatients() async {
    final rows = await _db.patientsDao.getAllPatients();
    return rows.map(_fromData).toList();
  }

  Stream<List<PatientModel>> watchAllPatients() =>
      _db.patientsDao.watchAllPatients().map((rows) => rows.map(_fromData).toList());

  Stream<List<PatientModel>> watchSearchPatients(String query) =>
      _db.patientsDao
          .watchSearchPatients(query)
          .map((rows) => rows.map(_fromData).toList());

  Future<PatientModel?> getPatientById(int id) async {
    final data = await _db.patientsDao.getPatientById(id);
    return data != null ? _fromData(data) : null;
  }

  Stream<PatientModel?> watchPatientById(int id) =>
      _db.patientsDao.watchPatientById(id).map((d) => d != null ? _fromData(d) : null);

  Future<int> getPatientsCount() => _db.patientsDao.getPatientsCount();

  // ─── Write ─────────────────────────────────────────────────

  Future<int> createPatient({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    String? gender,
    DateTime? birthDate,
    String? address,
    String? notes,
  }) =>
      _db.patientsDao.insertPatient(PatientsTableCompanion.insert(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: Value(email),
        gender: Value(gender),
        birthDate: Value(birthDate),
        address: Value(address),
        notes: Value(notes),
      ));

  Future<bool> updatePatient(PatientModel patient) =>
      _db.patientsDao.updatePatient(_toCompanion(patient));

  Future<int> deletePatient(int id) => _db.patientsDao.deletePatient(id);
}
