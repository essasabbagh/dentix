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
    required String doctorName,
    String? notes,
  }) {
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      // Allow past dates for historical entry
    }
    return _repository.createAppointment(
      patientId: patientId,
      date: date,
      doctorName: doctorName,
      notes: notes,
    );
  }

  Future<bool> updateAppointment(AppointmentModel appt) =>
      _repository.updateAppointment(appt);

  Future<void> updateStatus(int id, AppointmentStatus status) =>
      _repository.updateStatus(id, status);

  Future<int> deleteAppointment(int id) => _repository.deleteAppointment(id);
}
