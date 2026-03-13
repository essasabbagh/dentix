import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/payments_table.dart';
import '../tables/patients_table.dart';

part 'payments_dao.g.dart';

/// Joined payment + patient name for global list
class PaymentWithPatient {
  final PaymentsTableData payment;
  final String patientFullName;
  const PaymentWithPatient(this.payment, this.patientFullName);
}

@DriftAccessor(tables: [PaymentsTable, PatientsTable])
class PaymentsDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  /// All payments joined with patient name, newest first
  Stream<List<PaymentWithPatient>> watchAllPayments() {
    final query = select(paymentsTable).join([
      innerJoin(patientsTable,
          patientsTable.id.equalsExp(paymentsTable.patientId)),
    ])
      ..orderBy([
        OrderingTerm(
            expression: paymentsTable.paymentDate, mode: OrderingMode.desc)
      ]);
    return query.watch().map((rows) => rows
        .map((r) => PaymentWithPatient(
              r.readTable(paymentsTable),
              '${r.readTable(patientsTable).firstName} ${r.readTable(patientsTable).lastName}',
            ))
        .toList());
  }

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
