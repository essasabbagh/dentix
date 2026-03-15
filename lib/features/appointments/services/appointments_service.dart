import '../../../core/database/app_database.dart';
import '../data/appointments_repository.dart';
import '../models/appointment_model.dart';

class AppointmentsService {
  AppointmentsService(this._repository);
  final AppointmentsRepository _repository;

  Stream<List<AppointmentModel>> watchAppointmentsForDate(DateTime date) =>
      _repository.watchAppointmentsForDate(date);

  Stream<List<AppointmentModel>> watchPatientAppointments(int patientId) =>
      _repository.watchPatientAppointments(patientId);

  Future<int> getTodayCount() => _repository.getTodayCount();

  Future<int> createAppointment({
    required int patientId,
    required DateTime date,
    String? notes,
  }) {
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      // Allow past dates for historical entry
    }
    return _repository.createAppointment(
      patientId: patientId,
      date: date,
      notes: notes,
    );
  }

  Future<int> createAppointmentWithTreatments({
    required int patientId,
    required DateTime date,
    String? notes,
    required List<TreatmentsTableCompanion> treatments,
  }) {
    return _repository.createAppointmentWithTreatments(
      patientId: patientId,
      date: date,
      notes: notes,
      treatments: treatments,
    );
  }

  Future<AppointmentModel?> getAppointmentWithTreatments(int id) =>
      _repository.getAppointmentWithTreatments(id);

  Future<bool> updateAppointment(AppointmentModel appt) =>
      _repository.updateAppointment(appt);

  Future<void> updateStatus(int id, AppointmentStatus status) =>
      _repository.updateStatus(id, status);

  Future<int> deleteAppointment(int id) => _repository.deleteAppointment(id);
}
