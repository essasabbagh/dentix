import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:template/features/patients/providers/patients_providers.dart';

import '../data/odontogram_repository.dart';
import '../models/tooth_record.dart';
import '../services/odontogram_service.dart';

// ─── Repository & Service ─────────────────────────────────────────────────

final odontogramRepositoryProvider = Provider<OdontogramRepository>((ref) {
  return OdontogramRepository(ref.watch(appDatabaseProvider));
});

final odontogramServiceProvider = Provider<OdontogramService>((ref) {
  return OdontogramService(ref.watch(odontogramRepositoryProvider));
});

// ─── Patient teeth stream ─────────────────────────────────────────────────

final patientTeethProvider = StreamProvider.family<List<ToothRecord>, int>(
  (ref, patientId) =>
      ref.read(odontogramServiceProvider).watchPatientTeeth(patientId),
);

// ─── Derived: colorized map for TeethSelector ─────────────────────────────
//
// TeethSelector accepts:  Map<String, Color> colorized
// Keys are ISO tooth strings like "11", "36", "48"
// We build this map from the stored ToothRecord list.

final teethColorMapProvider = Provider.family<Map<String, Color>, int>((
  ref,
  patientId,
) {
  final teethAsync = ref.watch(patientTeethProvider(patientId));
  return teethAsync.when(
    data: (records) => {
      for (final r in records)
        if (r.condition != ToothCondition.healthy) r.isoKey: r.condition.color,
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// ─── Derived: stroked color map for TeethSelector ─────────────────────────

final teethStrokeColorMapProvider = Provider.family<Map<String, Color>, int>((
  ref,
  patientId,
) {
  final teethAsync = ref.watch(patientTeethProvider(patientId));
  return teethAsync.when(
    data: (records) => {
      for (final r in records)
        if (r.condition.strokeColor != Colors.transparent)
          r.isoKey: r.condition.strokeColor,
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// ─── Derived: lookup map  isoKey → ToothRecord ────────────────────────────

final teethRecordMapProvider = Provider.family<Map<String, ToothRecord>, int>((
  ref,
  patientId,
) {
  final teethAsync = ref.watch(patientTeethProvider(patientId));
  return teethAsync.when(
    data: (records) => {for (final r in records) r.isoKey: r},
    loading: () => {},
    error: (_, __) => {},
  );
});

// ─── Currently selected tooth (for the detail panel) ─────────────────────

final selectedToothProvider = StateProvider<String?>((ref) => null);

// ─── Odontogram action notifier ───────────────────────────────────────────

class OdontogramNotifier extends StateNotifier<AsyncValue<void>> {
  OdontogramNotifier(this._service, this.patientId)
    : super(const AsyncValue.data(null));
  final OdontogramService _service;
  final int patientId;

  Future<void> setCondition({
    required int toothNumber,
    required ToothCondition condition,
    String? treatmentType,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.setToothCondition(
        patientId: patientId,
        toothNumber: toothNumber,
        condition: condition,
        treatmentType: treatmentType,
        notes: notes,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resetTooth(int toothNumber) async {
    state = const AsyncValue.loading();
    try {
      await _service.resetTooth(patientId, toothNumber);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final odontogramNotifierProvider =
    StateNotifierProvider.family<OdontogramNotifier, AsyncValue<void>, int>((
      ref,
      patientId,
    ) {
      return OdontogramNotifier(
        ref.watch(odontogramServiceProvider),
        patientId,
      );
    });
