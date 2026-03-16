import 'package:drift/drift.dart';

import 'package:dentix/core/database/app_database.dart';

import '../models/payment_model.dart';

class PaymentsRepository {
  PaymentsRepository(this._db);
  final AppDatabase _db;

  PaymentModel _fromData(PaymentsTableData d) => PaymentModel(
    id: d.id,
    patientId: d.patientId,
    treatmentId: d.treatmentId,
    amount: d.amount,
    paymentDate: d.paymentDate,
    notes: d.notes,
    createdAt: d.createdAt,
  );

  Stream<List<PaymentModel>> watchPatientPayments(int patientId) => _db
      .paymentsDao
      .watchPatientPayments(patientId)
      .map((rows) => rows.map(_fromData).toList());

  Future<int> insertPayment({
    required int patientId,
    int? treatmentId,
    required double amount,
    String? notes,
  }) => _db.paymentsDao.insertPayment(
    PaymentsTableCompanion.insert(
      patientId: patientId,
      treatmentId: Value(treatmentId),
      amount: amount,
      notes: Value(notes),
    ),
  );

  Future<int> deletePayment(int id) => _db.paymentsDao.deletePayment(id);
}
