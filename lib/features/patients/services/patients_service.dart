import '../data/patients_repository.dart';
import '../models/patient_model.dart';

class PatientsService {
  PatientsService(this._repository);

  final PatientsRepository _repository;

  // ─── Streams ───────────────────────────────────────────────

  Stream<List<PatientModel>> watchAllPatients() =>
      _repository.watchAllPatients();

  Stream<List<PatientModel>> watchSearchPatients(String query) {
    if (query.trim().isEmpty) return _repository.watchAllPatients();
    return _repository.watchSearchPatients(query.trim());
  }

  Stream<PatientModel?> watchPatientById(int id) =>
      _repository.watchPatientById(id);

  // ─── Queries ───────────────────────────────────────────────

  Future<PatientModel?> getPatientById(int id) =>
      _repository.getPatientById(id);

  Future<int> getPatientsCount() => _repository.getPatientsCount();

  // ─── Commands ──────────────────────────────────────────────

  Future<int> createPatient({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    String? gender,
    DateTime? birthDate,
    String? address,
    String? notes,
  }) async {
    _validatePatient(firstName: firstName, lastName: lastName, phone: phone);
    return _repository.createPatient(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone.trim(),
      email: email?.trim(),
      gender: gender,
      birthDate: birthDate,
      address: address?.trim(),
      notes: notes?.trim(),
    );
  }

  Future<bool> updatePatient(PatientModel patient) async {
    _validatePatient(
      firstName: patient.firstName,
      lastName: patient.lastName,
      phone: patient.phone,
    );
    return _repository.updatePatient(patient);
  }

  Future<void> deletePatient(int id) async {
    await _repository.deletePatient(id);
  }

  // ─── Validation ────────────────────────────────────────────

  void _validatePatient({
    required String firstName,
    required String lastName,
    required String phone,
  }) {
    if (firstName.trim().isEmpty) {
      throw Exception('الاسم الأول مطلوب');
    }
    if (lastName.trim().isEmpty) {
      throw Exception('اسم العائلة مطلوب');
    }
    if (phone.trim().isEmpty) {
      throw Exception('رقم الهاتف مطلوب');
    }
    if (phone.trim().length < 9) {
      throw Exception('رقم الهاتف غير صحيح');
    }
  }
}
