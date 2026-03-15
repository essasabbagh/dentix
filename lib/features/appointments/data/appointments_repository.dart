import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../patients/models/patient_model.dart';
import '../models/appointment_model.dart';

class AppointmentsRepository {
  AppointmentsRepository(this._db);
  final AppDatabase _db;

  // ─── Mappers ───────────────────────────────────────────────

  AppointmentModel _fromData(
    AppointmentsTableData d, {
    PatientModel? patient,
  }) => AppointmentModel(
    id: d.id,
    patientId: d.patientId,
    appointmentDate: d.appointmentDate,
    status: AppointmentStatus.fromDb(d.status),
    notes: d.notes,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
    patient: patient,
  );

  PatientModel _patientFromData(PatientsTableData d) => PatientModel(
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

  // ─── Streams / Queries ─────────────────────────────────────

  Stream<List<AppointmentModel>> watchAppointmentsForDate(DateTime date) => _db
      .appointmentsDao
      .watchAppointmentsForDate(date)
      .map(
        (rows) => rows
            .map(
              (r) => _fromData(
                r.appointment,
                patient: _patientFromData(r.patient),
              ),
            )
            .toList(),
      );

  Future<List<AppointmentModel>> getAppointmentsForDate(DateTime date) async {
    final rows = await _db.appointmentsDao.getAppointmentsForDate(date);
    return rows
        .map(
          (r) => _fromData(r.appointment, patient: _patientFromData(r.patient)),
        )
        .toList();
  }

  Stream<List<AppointmentModel>> watchPatientAppointments(int patientId) => _db
      .appointmentsDao
      .watchPatientAppointments(patientId)
      .map((rows) => rows.map(_fromData).toList());

  Future<int> getTodayCount() =>
      _db.appointmentsDao.getTodayAppointmentsCount();

  // ─── Write ─────────────────────────────────────────────────

  Future<int> createAppointment({
    required int patientId,
    required DateTime date,
    String status = 'scheduled',
    String? notes,
  }) => _db.appointmentsDao.insertAppointment(
    AppointmentsTableCompanion.insert(
      patientId: patientId,
      appointmentDate: date,
      status: Value(status),
      notes: Value(notes),
    ),
  );

  Future<int> createAppointmentWithTreatments({
    required int patientId,
    required DateTime date,
    String? notes,
    required List<TreatmentsTableCompanion> treatments,
  }) async {
    return _db.transaction(() async {
      final appointmentId = await _db.appointmentsDao.insertAppointment(
        AppointmentsTableCompanion.insert(
          patientId: patientId,
          appointmentDate: date,
          notes: Value(notes),
        ),
      );

      for (var t in treatments) {
        await _db.treatmentsDao.insertTreatment(
          t.copyWith(appointmentId: Value(appointmentId)),
        );
      }

      return appointmentId;
    });
  }

  Future<bool> updateAppointment(AppointmentModel appt) =>
      _db.appointmentsDao.updateAppointment(
        AppointmentsTableCompanion(
          id: Value(appt.id),
          patientId: Value(appt.patientId),
          appointmentDate: Value(appt.appointmentDate),
          status: Value(appt.status.dbValue),
          notes: Value(appt.notes),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> updateStatus(int id, AppointmentStatus status) =>
      _db.appointmentsDao.updateStatus(id, status.dbValue);

  Future<int> deleteAppointment(int id) =>
      _db.appointmentsDao.deleteAppointment(id);
}
