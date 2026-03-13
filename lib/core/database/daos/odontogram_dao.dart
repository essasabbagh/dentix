import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/odontogram_table.dart';

part 'odontogram_dao.g.dart';

@DriftAccessor(tables: [OdontogramTable])
class OdontogramDao extends DatabaseAccessor<AppDatabase>
    with _$OdontogramDaoMixin {
  OdontogramDao(super.db);

  Stream<List<OdontogramTableData>> watchPatientTeeth(int patientId) =>
      (select(odontogramTable)
            ..where((t) => t.patientId.equals(patientId)))
          .watch();

  Future<OdontogramTableData?> getTooth(int patientId, int toothNumber) =>
      (select(odontogramTable)
            ..where((t) =>
                t.patientId.equals(patientId) &
                t.toothNumber.equals(toothNumber)))
          .getSingleOrNull();

  Future<int> upsertTooth(OdontogramTableCompanion tooth) =>
      into(odontogramTable).insertOnConflictUpdate(tooth);

  Future<int> deleteTooth(int patientId, int toothNumber) =>
      (delete(odontogramTable)
            ..where((t) =>
                t.patientId.equals(patientId) &
                t.toothNumber.equals(toothNumber)))
          .go();
}
