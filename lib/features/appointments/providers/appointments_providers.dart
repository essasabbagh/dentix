import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/database/app_database_provider.dart';

import '../data/appointments_repository.dart';
import '../models/appointment_model.dart';
import '../services/appointments_service.dart';

// ─── Repository ───────────────────────────────────────────────────────────
final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return AppointmentsRepository(ref.watch(appDatabaseProvider));
});

// ─── Service ──────────────────────────────────────────────────────────────
final appointmentsServiceProvider = Provider<AppointmentsService>((ref) {
  return AppointmentsService(ref.watch(appointmentsRepositoryProvider));
});

// ─── Selected date (for daily view) ──────────────────────────────────────
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// ─── Appointments for selected date ──────────────────────────────────────
final appointmentsForDateProvider = StreamProvider<List<AppointmentModel>>((
  ref,
) {
  final service = ref.watch(appointmentsServiceProvider);
  final date = ref.watch(selectedDateProvider);
  return service.watchAppointmentsForDate(date);
});

// ─── Today count (dashboard) ──────────────────────────────────────────────
final todayAppointmentsCountProvider = FutureProvider<int>((ref) {
  ref.watch(appointmentsForDateProvider); // refresh dependency
  return ref.watch(appointmentsServiceProvider).getTodayCount();
});

// ─── Patient appointments stream ──────────────────────────────────────────
final patientAppointmentsProvider =
    StreamProvider.family<List<AppointmentModel>, int>((ref, patientId) {
      return ref
          .watch(appointmentsServiceProvider)
          .watchPatientAppointments(patientId);
    });

// ─── Appointment form notifier ────────────────────────────────────────────
class AppointmentFormNotifier extends StateNotifier<AsyncValue<void>> {
  AppointmentFormNotifier(this._service) : super(const AsyncValue.data(null));
  final AppointmentsService _service;

  Future<bool> createAppointment({
    required int patientId,
    required DateTime date,
    required String doctorName,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.createAppointment(
        patientId: patientId,
        date: date,
        doctorName: doctorName,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateStatus(int id, AppointmentStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateStatus(id, status);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteAppointment(int id) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteAppointment(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final appointmentFormProvider =
    StateNotifierProvider<AppointmentFormNotifier, AsyncValue<void>>(
      (ref) => AppointmentFormNotifier(ref.watch(appointmentsServiceProvider)),
    );
