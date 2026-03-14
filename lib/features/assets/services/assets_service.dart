import 'dart:io';

import '../data/assets_repository.dart';
import '../models/asset_model.dart';

class AssetsService {
  AssetsService(this._repository);
  final AssetsRepository _repository;

  // ─── Streams ───────────────────────────────────────────────

  Stream<List<AssetModel>> watchPatientAssets(int patientId) =>
      _repository.watchPatientAssets(patientId);

  Stream<List<AssetModel>> watchTreatmentAssets(int treatmentId) =>
      _repository.watchTreatmentAssets(treatmentId);

  // ─── Add ───────────────────────────────────────────────────

  Future<AssetModel> addPatientAsset({
    required int patientId,
    required File file,
    String? label,
  }) => _repository.addAsset(
    patientId: patientId,
    sourceFile: file,
    mimeType: _detectMime(file.path),
    label: label,
  );

  Future<AssetModel> addTreatmentAsset({
    required int treatmentId,
    required File file,
    String? label,
  }) => _repository.addAsset(
    treatmentId: treatmentId,
    sourceFile: file,
    mimeType: _detectMime(file.path),
    label: label,
  );

  // ─── Delete ────────────────────────────────────────────────

  Future<void> deleteAsset(AssetModel asset) => _repository.deleteAsset(asset);

  Future<void> deleteAllPatientAssets(int patientId) =>
      _repository.deleteAllPatientAssets(patientId);

  Future<void> deleteAllTreatmentAssets(int treatmentId) =>
      _repository.deleteAllTreatmentAssets(treatmentId);

  // ─── MIME detection from extension ────────────────────────

  String _detectMime(String path) {
    final ext = path.split('.').last.toLowerCase();
    const map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'bmp': 'image/bmp',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
    };
    return map[ext] ?? 'application/octet-stream';
  }
}
