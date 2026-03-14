import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/database/app_database_provider.dart';

import '../../../../core/database/daos/payments_dao.dart';
import '../data/payments_repository.dart';
import '../models/payment_model.dart';

// ─── Repository ───────────────────────────────────────────────────────────
final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.watch(appDatabaseProvider));
});

// ─── All payments stream (with patient name) ──────────────────────────────
final allPaymentsProvider = StreamProvider<List<PaymentWithPatient>>((ref) {
  return ref.watch(appDatabaseProvider).paymentsDao.watchAllPayments();
});

// ─── Patient payments stream ──────────────────────────────────────────────
final patientPaymentsProvider = StreamProvider.family<List<PaymentModel>, int>((
  ref,
  patientId,
) {
  return ref.watch(paymentsRepositoryProvider).watchPatientPayments(patientId);
});

// ─── Patient total balance ────────────────────────────────────────────────
final patientTotalPaidProvider = Provider.family<AsyncValue<double>, int>((
  ref,
  patientId,
) {
  return ref
      .watch(patientPaymentsProvider(patientId))
      .whenData(
        (payments) => payments.fold(0.0, (sum, p) => sum + p.amount),
      );
});

// ─── Filter state ─────────────────────────────────────────────────────────
class PaymentsFilter {
  const PaymentsFilter({
    this.query = '',
    this.dateFrom,
    this.dateTo,
  });
  final String query;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  PaymentsFilter copyWith({
    String? query,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
  }) => PaymentsFilter(
    query: query ?? this.query,
    dateFrom: dateFrom == _sentinel ? this.dateFrom : dateFrom as DateTime?,
    dateTo: dateTo == _sentinel ? this.dateTo : dateTo as DateTime?,
  );

  bool get hasActiveFilters =>
      query.isNotEmpty || dateFrom != null || dateTo != null;
}

const _sentinel = Object();

final paymentsFilterProvider = StateProvider<PaymentsFilter>(
  (ref) => const PaymentsFilter(),
);

// ─── Filtered list ────────────────────────────────────────────────────────
final filteredPaymentsProvider = Provider<AsyncValue<List<PaymentWithPatient>>>(
  (ref) {
    final all = ref.watch(allPaymentsProvider);
    final filter = ref.watch(paymentsFilterProvider);

    return all.whenData((list) {
      var result = list;

      if (filter.query.isNotEmpty) {
        final q = filter.query.toLowerCase();
        result = result
            .where((p) => p.patientFullName.toLowerCase().contains(q))
            .toList();
      }

      if (filter.dateFrom != null) {
        result = result
            .where(
              (p) => p.payment.paymentDate.isAfter(
                filter.dateFrom!.subtract(const Duration(days: 1)),
              ),
            )
            .toList();
      }

      if (filter.dateTo != null) {
        result = result
            .where(
              (p) => p.payment.paymentDate.isBefore(
                filter.dateTo!.add(const Duration(days: 1)),
              ),
            )
            .toList();
      }

      return result;
    });
  },
);

// ─── Summary stats ────────────────────────────────────────────────────────
final paymentsSummaryProvider = Provider<AsyncValue<_PaymentsSummary>>(
  (ref) {
    final filtered = ref.watch(filteredPaymentsProvider);
    return filtered.whenData((list) {
      final totalPaid = list.fold<double>(0, (s, p) => s + p.payment.amount);
      return _PaymentsSummary(
        count: list.length,
        totalPaid: totalPaid,
      );
    });
  },
);

class _PaymentsSummary {
  const _PaymentsSummary({
    required this.count,
    required this.totalPaid,
  });
  final int count;
  final double totalPaid;
}

// ─── Payment form notifier ────────────────────────────────────────────────
class PaymentFormNotifier extends StateNotifier<AsyncValue<void>> {
  PaymentFormNotifier(this._repo) : super(const AsyncValue.data(null));
  final PaymentsRepository _repo;

  Future<bool> create({
    required int patientId,
    int? treatmentId,
    required double amount,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.insertPayment(
        patientId: patientId,
        treatmentId: treatmentId,
        amount: amount,
        notes: notes,
      );
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
      await _repo.deletePayment(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final paymentFormProvider =
    StateNotifierProvider<PaymentFormNotifier, AsyncValue<void>>((ref) {
      return PaymentFormNotifier(ref.watch(paymentsRepositoryProvider));
    });
