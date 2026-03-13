import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/payments_table.dart';

part 'payments_dao.g.dart';

@DriftAccessor(tables: [PaymentsTable])
class PaymentsDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  Stream<List<PaymentsTableData>> watchPatientPayments(int patientId) =>
      (select(paymentsTable)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([(t) => OrderingTerm(
                expression: t.paymentDate, mode: OrderingMode.desc)]))
          .watch();

  /// Monthly income
  Future<double> getMonthlyIncome(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final sum = paymentsTable.amount.sum();
    final query = selectOnly(paymentsTable)
      ..addColumns([sum])
      ..where(paymentsTable.paymentStatus.equals('paid') &
          paymentsTable.paymentDate.isBiggerOrEqualValue(start) &
          paymentsTable.paymentDate.isSmallerThanValue(end));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  Future<int> insertPayment(PaymentsTableCompanion p) =>
      into(paymentsTable).insert(p);

  Future<bool> updatePayment(PaymentsTableCompanion p) =>
      update(paymentsTable).replace(p);

  Future<int> deletePayment(int id) =>
      (delete(paymentsTable)..where((t) => t.id.equals(id))).go();
}
