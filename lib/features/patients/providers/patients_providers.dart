import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../data/patients_repository.dart';
import '../models/patient_model.dart';
import '../services/patients_service.dart';

// ─── Database provider (global singleton) ─────────────────────────────────
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ─── Repository ───────────────────────────────────────────────────────────
final patientsRepositoryProvider = Provider<PatientsRepository>((ref) {
  return PatientsRepository(ref.watch(appDatabaseProvider));
});

// ─── Service ──────────────────────────────────────────────────────────────
final patientsServiceProvider = Provider<PatientsService>((ref) {
  return PatientsService(ref.watch(patientsRepositoryProvider));
});

// ─── Search query state ───────────────────────────────────────────────────
final patientSearchQueryProvider = StateProvider<String>((ref) => '');

// ─── Patients list (reactive, respects search) ────────────────────────────
final patientsListProvider = StreamProvider<List<PatientModel>>((ref) {
  final service = ref.watch(patientsServiceProvider);
  final query = ref.watch(patientSearchQueryProvider);
  return service.watchSearchPatients(query);
});

// ─── Single patient ───────────────────────────────────────────────────────
final patientByIdProvider =
    StreamProvider.family<PatientModel?, int>((ref, id) {
  return ref.watch(patientsServiceProvider).watchPatientById(id);
});

// ─── Patients count ───────────────────────────────────────────────────────
final patientsCountProvider = FutureProvider<int>((ref) {
  // Refresh when the list changes
  ref.watch(patientsListProvider);
  return ref.watch(patientsServiceProvider).getPatientsCount();
});

// ─── Patient form notifier ────────────────────────────────────────────────
class PatientFormNotifier extends StateNotifier<AsyncValue<void>> {
  final PatientsService _service;

  PatientFormNotifier(this._service) : super(const AsyncValue.data(null));

  Future<bool> createPatient({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    String? gender,
    DateTime? birthDate,
    String? address,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.createPatient(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        gender: gender,
        birthDate: birthDate,
        address: address,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updatePatient(PatientModel patient) async {
    state = const AsyncValue.loading();
    try {
      await _service.updatePatient(patient);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deletePatient(int id) async {
    state = const AsyncValue.loading();
    try {
      await _service.deletePatient(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final patientFormProvider =
    StateNotifierProvider<PatientFormNotifier, AsyncValue<void>>((ref) {
  return PatientFormNotifier(ref.watch(patientsServiceProvider));
});
