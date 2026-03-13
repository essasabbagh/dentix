import '../data/odontogram_repository.dart';
import '../models/tooth_record.dart';

class OdontogramService {
  OdontogramService(this._repository);

  final OdontogramRepository _repository;

  Stream<List<ToothRecord>> watchPatientTeeth(int patientId) =>
      _repository.watchPatientTeeth(patientId);

  Future<void> setToothCondition({
    required int patientId,
    required int toothNumber,
    required ToothCondition condition,
    String? treatmentType,
    String? notes,
  }) async {
    if (condition == ToothCondition.healthy &&
        treatmentType == null &&
        notes == null) {
      // No reason to store a healthy tooth with no notes — delete it
      await _repository.resetTooth(patientId, toothNumber);
    } else {
      await _repository.upsertTooth(
        patientId: patientId,
        toothNumber: toothNumber,
        condition: condition,
        treatmentType: treatmentType,
        notes: notes,
      );
    }
  }

  Future<void> resetTooth(int patientId, int toothNumber) =>
      _repository.resetTooth(patientId, toothNumber);
}
