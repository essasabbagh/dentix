import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/assets_table.dart';

part 'assets_dao.g.dart';

@DriftAccessor(tables: [AssetsTable])
class AssetsDao extends DatabaseAccessor<AppDatabase> with _$AssetsDaoMixin {
  AssetsDao(super.db);

  // ─── Patient assets ────────────────────────────────────────────────
  Stream<List<AssetsTableData>> watchPatientAssets(int patientId) =>
      (select(assetsTable)
            ..where((a) => a.patientId.equals(patientId))
            ..orderBy([
              (a) => OrderingTerm(
                expression: a.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<List<AssetsTableData>> getPatientAssets(int patientId) =>
      (select(assetsTable)
            ..where((a) => a.patientId.equals(patientId))
            ..orderBy([
              (a) => OrderingTerm(
                expression: a.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  // ─── Treatment assets ──────────────────────────────────────────────
  Stream<List<AssetsTableData>> watchTreatmentAssets(int treatmentId) =>
      (select(assetsTable)
            ..where((a) => a.treatmentId.equals(treatmentId))
            ..orderBy([
              (a) => OrderingTerm(
                expression: a.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<List<AssetsTableData>> getTreatmentAssets(int treatmentId) =>
      (select(assetsTable)
            ..where((a) => a.treatmentId.equals(treatmentId))
            ..orderBy([
              (a) => OrderingTerm(
                expression: a.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  // ─── Mutations ─────────────────────────────────────────────────────
  Future<int> insertAsset(AssetsTableCompanion asset) =>
      into(assetsTable).insert(asset);

  Future<AssetsTableData?> getAssetById(int id) =>
      (select(assetsTable)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<int> deleteAsset(int id) =>
      (delete(assetsTable)..where((a) => a.id.equals(id))).go();

  /// Delete all assets for a patient (used before patient delete)
  Future<int> deletePatientAssets(int patientId) =>
      (delete(assetsTable)..where((a) => a.patientId.equals(patientId))).go();

  /// Delete all assets for a treatment
  Future<int> deleteTreatmentAssets(int treatmentId) => (delete(
    assetsTable,
  )..where((a) => a.treatmentId.equals(treatmentId))).go();
}
