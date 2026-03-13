import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../models/treatment_model.dart';

class TreatmentsRepository {
  final AppDatabase _db;
  TreatmentsRepository(this._db);

  TreatmentModel _fromData(TreatmentsTableData d) => TreatmentModel(
        id: d.id,
        patientId: d.patientId,
        appointmentId: d.appointmentId,
        treatmentType: d.treatmentType,
        toothNumber: d.toothNumber,
        price: d.price,
        status: TreatmentStatus.fromDb(d.status),
        notes: d.notes,
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
      );

  Stream<List<TreatmentModel>> watchPatientTreatments(int patientId) =>
      _db.treatmentsDao
          .watchPatientTreatments(patientId)
          .map((rows) => rows.map(_fromData).toList());

  Future<int> insertTreatment({
    required int patientId,
    int? appointmentId,
    required String treatmentType,
    int? toothNumber,
    required double price,
    String status = 'planned',
    String? notes,
  }) =>
      _db.treatmentsDao.insertTreatment(TreatmentsTableCompanion.insert(
        patientId: patientId,
        appointmentId: Value(appointmentId),
        treatmentType: treatmentType,
        toothNumber: Value(toothNumber),
        price: Value(price),
        status: Value(status),
        notes: Value(notes),
      ));

  Future<bool> updateTreatment(TreatmentModel t) =>
      _db.treatmentsDao.updateTreatment(TreatmentsTableCompanion(
        id: Value(t.id),
        patientId: Value(t.patientId),
        appointmentId: Value(t.appointmentId),
        treatmentType: Value(t.treatmentType),
        toothNumber: Value(t.toothNumber),
        price: Value(t.price),
        status: Value(t.status.dbValue),
        notes: Value(t.notes),
        updatedAt: Value(DateTime.now()),
      ));

  Future<void> completeTreatment(int id) =>
      _db.treatmentsDao.completeTreatment(id);

  Future<int> deleteTreatment(int id) =>
      _db.treatmentsDao.deleteTreatment(id);
}
