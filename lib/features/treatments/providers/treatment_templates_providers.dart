import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:template/core/database/app_database.dart';
import 'package:template/core/database/app_database_provider.dart';

final treatmentTemplatesProvider =
    StreamProvider<List<TreatmentTemplatesTableData>>((ref) {
  return ref.watch(appDatabaseProvider).treatmentTemplatesDao.watchAllTemplates();
});

class TreatmentTemplateNotifier extends StateNotifier<AsyncValue<void>> {
  TreatmentTemplateNotifier(this._db) : super(const AsyncValue.data(null));
  final AppDatabase _db;

  Future<void> addTemplate(String name, double defaultPrice) async {
    state = const AsyncValue.loading();
    try {
      await _db.treatmentTemplatesDao.insertTemplate(
        TreatmentTemplatesTableCompanion.insert(
          name: name,
          defaultPrice: Value(defaultPrice),
        ),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTemplate(int id, String name, double defaultPrice) async {
    state = const AsyncValue.loading();
    try {
      await _db.treatmentTemplatesDao.updateTemplate(
        TreatmentTemplatesTableCompanion(
          id: Value(id),
          name: Value(name),
          defaultPrice: Value(defaultPrice),
          updatedAt: Value(DateTime.now()),
        ),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTemplate(int id) async {
    state = const AsyncValue.loading();
    try {
      await _db.treatmentTemplatesDao.deleteTemplate(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final treatmentTemplateFormProvider =
    StateNotifierProvider<TreatmentTemplateNotifier, AsyncValue<void>>((ref) {
  return TreatmentTemplateNotifier(ref.watch(appDatabaseProvider));
});
