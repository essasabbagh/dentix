import 'package:drift/drift.dart';

import 'package:template/core/database/app_database.dart';

import '../models/tooth_record.dart';

class OdontogramRepository {
  OdontogramRepository(this._db);
  final AppDatabase _db;

  // ─── Mapper ────────────────────────────────────────────────

  ToothRecord _fromData(OdontogramTableData d) => ToothRecord(
    id: d.id,
    patientId: d.patientId,
    toothNumber: d.toothNumber,
    condition: ToothCondition.fromDb(d.condition),
    treatmentType: d.treatmentType,
    notes: d.notes,
    updatedAt: d.updatedAt,
  );

  // ─── Streams ───────────────────────────────────────────────

  /// Returns a live stream of all tooth records for a patient.
  /// Only teeth that have been touched (non-healthy or have notes) are stored.
  Stream<List<ToothRecord>> watchPatientTeeth(int patientId) => _db
      .odontogramDao
      .watchPatientTeeth(patientId)
      .map((rows) => rows.map(_fromData).toList());

  // ─── Write ─────────────────────────────────────────────────

  /// Upsert a tooth record (insert or update by patient_id + tooth_number).
  Future<void> upsertTooth({
    required int patientId,
    required int toothNumber,
    required ToothCondition condition,
    String? treatmentType,
    String? notes,
  }) => _db.odontogramDao.upsertTooth(
    OdontogramTableCompanion(
      patientId: Value(patientId),
      toothNumber: Value(toothNumber),
      condition: Value(condition.dbValue),
      treatmentType: Value(treatmentType),
      notes: Value(notes),
      updatedAt: Value(DateTime.now()),
    ),
  );

  /// Reset a tooth back to healthy (deletes the record).
  Future<void> resetTooth(int patientId, int toothNumber) =>
      _db.odontogramDao.deleteTooth(patientId, toothNumber);
}
