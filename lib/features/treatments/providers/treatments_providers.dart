import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/features/patients/providers/patients_providers.dart';

import '../../../../core/database/daos/treatments_dao.dart';
import '../data/treatments_repository.dart';
import '../models/treatment_model.dart';

// ─── Repository ───────────────────────────────────────────────────────────
final treatmentsRepositoryProvider = Provider<TreatmentsRepository>((ref) {
  return TreatmentsRepository(ref.watch(appDatabaseProvider));
});

// ─── All treatments stream (with patient name) ────────────────────────────
final allTreatmentsProvider = StreamProvider<List<TreatmentWithPatient>>((ref) {
  return ref.watch(appDatabaseProvider).treatmentsDao.watchAllTreatments();
});

// ─── Patient treatments stream ────────────────────────────────────────────
final patientTreatmentsProvider =
    StreamProvider.family<List<TreatmentModel>, int>((ref, patientId) {
      return ref
          .watch(treatmentsRepositoryProvider)
          .watchPatientTreatments(patientId);
    });

// ─── Filter state ─────────────────────────────────────────────────────────
class TreatmentsFilter {
  const TreatmentsFilter({
    this.query = '',
    this.status,
    this.dateFrom,
    this.dateTo,
  });
  final String query;
  final TreatmentStatus? status;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  TreatmentsFilter copyWith({
    String? query,
    Object? status = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
  }) => TreatmentsFilter(
    query: query ?? this.query,
    status: status == _sentinel ? this.status : status as TreatmentStatus?,
    dateFrom: dateFrom == _sentinel ? this.dateFrom : dateFrom as DateTime?,
    dateTo: dateTo == _sentinel ? this.dateTo : dateTo as DateTime?,
  );

  bool get hasActiveFilters =>
      query.isNotEmpty || status != null || dateFrom != null || dateTo != null;
}

const _sentinel = Object();

final treatmentsFilterProvider = StateProvider<TreatmentsFilter>(
  (ref) => const TreatmentsFilter(),
);

// ─── Filtered list ────────────────────────────────────────────────────────
final filteredTreatmentsProvider =
    Provider<AsyncValue<List<TreatmentWithPatient>>>((ref) {
      final all = ref.watch(allTreatmentsProvider);
      final filter = ref.watch(treatmentsFilterProvider);

      return all.whenData((list) {
        var result = list;

        if (filter.query.isNotEmpty) {
          final q = filter.query.toLowerCase();
          result = result
              .where(
                (t) =>
                    t.patientFullName.toLowerCase().contains(q) ||
                    t.treatment.treatmentType.toLowerCase().contains(q),
              )
              .toList();
        }

        if (filter.status != null) {
          result = result
              .where(
                (t) =>
                    TreatmentStatus.fromDb(t.treatment.status) == filter.status,
              )
              .toList();
        }

        if (filter.dateFrom != null) {
          result = result
              .where(
                (t) => t.treatment.createdAt.isAfter(
                  filter.dateFrom!.subtract(const Duration(days: 1)),
                ),
              )
              .toList();
        }

        if (filter.dateTo != null) {
          result = result
              .where(
                (t) => t.treatment.createdAt.isBefore(
                  filter.dateTo!.add(const Duration(days: 1)),
                ),
              )
              .toList();
        }

        return result;
      });
    });

// ─── Summary stats ────────────────────────────────────────────────────────
final treatmentsSummaryProvider = Provider<AsyncValue<_TreatmentsSummary>>(
  (ref) {
    final filtered = ref.watch(filteredTreatmentsProvider);
    return filtered.whenData((list) {
      final total = list.fold<double>(0, (s, t) => s + t.treatment.price);
      final completed = list
          .where((t) => t.treatment.status == 'completed')
          .fold<double>(0, (s, t) => s + t.treatment.price);
      return _TreatmentsSummary(
        count: list.length,
        total: total,
        completed: completed,
      );
    });
  },
);

class _TreatmentsSummary {
  const _TreatmentsSummary({
    required this.count,
    required this.total,
    required this.completed,
  });
  final int count;
  final double total;
  final double completed;
}

// ─── Treatment form notifier ──────────────────────────────────────────────
class TreatmentFormNotifier extends StateNotifier<AsyncValue<void>> {
  TreatmentFormNotifier(this._repo) : super(const AsyncValue.data(null));
  final TreatmentsRepository _repo;

  Future<bool> create({
    required int patientId,
    int? appointmentId,
    required String treatmentType,
    int? toothNumber,
    required double price,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.insertTreatment(
        patientId: patientId,
        appointmentId: appointmentId,
        treatmentType: treatmentType,
        toothNumber: toothNumber,
        price: price,
        notes: notes,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> update(TreatmentModel t) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateTreatment(t);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> complete(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.completeTreatment(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> delete(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteTreatment(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final treatmentFormProvider =
    StateNotifierProvider<TreatmentFormNotifier, AsyncValue<void>>((ref) {
      return TreatmentFormNotifier(ref.watch(treatmentsRepositoryProvider));
    });
