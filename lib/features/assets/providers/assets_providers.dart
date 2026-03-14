import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:template/features/patients/providers/patients_providers.dart';

import '../data/assets_repository.dart';
import '../models/asset_model.dart';
import '../services/assets_service.dart';

// ─── Repository & Service ─────────────────────────────────────────────────

final assetsRepositoryProvider = Provider<AssetsRepository>((ref) {
  return AssetsRepository(ref.watch(appDatabaseProvider));
});

final assetsServiceProvider = Provider<AssetsService>((ref) {
  return AssetsService(ref.watch(assetsRepositoryProvider));
});

// ─── Patient assets stream ────────────────────────────────────────────────

final patientAssetsProvider = StreamProvider.family<List<AssetModel>, int>((
  ref,
  patientId,
) {
  return ref.watch(assetsServiceProvider).watchPatientAssets(patientId);
});

// ─── Treatment assets stream ──────────────────────────────────────────────

final treatmentAssetsProvider = StreamProvider.family<List<AssetModel>, int>((
  ref,
  treatmentId,
) {
  return ref.watch(assetsServiceProvider).watchTreatmentAssets(treatmentId);
});

// ─── Asset action notifier ────────────────────────────────────────────────

class AssetNotifier extends StateNotifier<AsyncValue<void>> {
  AssetNotifier(this._service) : super(const AsyncValue.data(null));
  final AssetsService _service;

  Future<AssetModel?> addPatientAsset({
    required int patientId,
    required File file,
    String? label,
  }) async {
    state = const AsyncValue.loading();
    try {
      final asset = await _service.addPatientAsset(
        patientId: patientId,
        file: file,
        label: label,
      );
      state = const AsyncValue.data(null);
      return asset;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<AssetModel?> addTreatmentAsset({
    required int treatmentId,
    required File file,
    String? label,
  }) async {
    state = const AsyncValue.loading();
    try {
      final asset = await _service.addTreatmentAsset(
        treatmentId: treatmentId,
        file: file,
        label: label,
      );
      state = const AsyncValue.data(null);
      return asset;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deleteAsset(AssetModel asset) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteAsset(asset);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final assetNotifierProvider =
    StateNotifierProvider<AssetNotifier, AsyncValue<void>>((ref) {
      return AssetNotifier(ref.watch(assetsServiceProvider));
    });
