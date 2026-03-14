import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../models/asset_model.dart';

class AssetsRepository {
  AssetsRepository(this._db);
  final AppDatabase _db;

  // ─── Mapper ────────────────────────────────────────────────

  AssetModel _fromData(AssetsTableData d) => AssetModel(
    id: d.id,
    patientId: d.patientId,
    treatmentId: d.treatmentId,
    fileName: d.fileName,
    filePath: d.filePath,
    mimeType: d.mimeType,
    sizeBytes: d.sizeBytes,
    label: d.label,
    createdAt: d.createdAt,
  );

  // ─── Storage directory ─────────────────────────────────────

  Future<Directory> _assetsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'dentixflow', 'assets'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ─── Streams ───────────────────────────────────────────────

  Stream<List<AssetModel>> watchPatientAssets(int patientId) => _db.assetsDao
      .watchPatientAssets(patientId)
      .map((rows) => rows.map(_fromData).toList());

  Stream<List<AssetModel>> watchTreatmentAssets(int treatmentId) => _db
      .assetsDao
      .watchTreatmentAssets(treatmentId)
      .map((rows) => rows.map(_fromData).toList());

  // ─── Write ─────────────────────────────────────────────────

  /// Copies [sourceFile] into the app's assets folder, then saves a DB record.
  /// Returns the new [AssetModel].
  Future<AssetModel> addAsset({
    int? patientId,
    int? treatmentId,
    required File sourceFile,
    required String mimeType,
    String? label,
  }) async {
    assert(
      patientId != null || treatmentId != null,
      'Asset must belong to a patient or treatment',
    );

    final dir = await _assetsDir();
    final ext = p.extension(sourceFile.path);
    final uuid = DateTime.now().millisecondsSinceEpoch.toString();
    final destName = '$uuid$ext';
    final destPath = p.join(dir.path, destName);

    // Copy file to permanent location
    await sourceFile.copy(destPath);

    final stat = await sourceFile.stat();
    final fileName = p.basename(sourceFile.path);

    final id = await _db.assetsDao.insertAsset(
      AssetsTableCompanion.insert(
        patientId: Value(patientId),
        treatmentId: Value(treatmentId),
        fileName: fileName,
        filePath: destPath,
        mimeType: mimeType,
        sizeBytes: stat.size,
        label: Value(label),
      ),
    );

    final data = await _db.assetsDao.getAssetById(id);
    return _fromData(data!);
  }

  /// Deletes the DB record AND the file from disk.
  Future<void> deleteAsset(AssetModel asset) async {
    await _db.assetsDao.deleteAsset(asset.id);
    final file = File(asset.filePath);
    if (await file.exists()) await file.delete();
  }

  /// Delete all patient assets from DB + disk (call before deleting patient).
  Future<void> deleteAllPatientAssets(int patientId) async {
    final assets = await _db.assetsDao.getPatientAssets(patientId);
    for (final a in assets) {
      final file = File(a.filePath);
      if (await file.exists()) await file.delete();
    }
    await _db.assetsDao.deletePatientAssets(patientId);
  }

  /// Delete all treatment assets from DB + disk.
  Future<void> deleteAllTreatmentAssets(int treatmentId) async {
    final assets = await _db.assetsDao.getTreatmentAssets(treatmentId);
    for (final a in assets) {
      final file = File(a.filePath);
      if (await file.exists()) await file.delete();
    }
    await _db.assetsDao.deleteTreatmentAssets(treatmentId);
  }
}
