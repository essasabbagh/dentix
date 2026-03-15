import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/treatment_templates_table.dart';

part 'treatment_templates_dao.g.dart';

@DriftAccessor(tables: [TreatmentTemplatesTable])
class TreatmentTemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$TreatmentTemplatesDaoMixin {
  TreatmentTemplatesDao(super.db);

  Stream<List<TreatmentTemplatesTableData>> watchAllTemplates() =>
      select(treatmentTemplatesTable).watch();

  Future<List<TreatmentTemplatesTableData>> getAllTemplates() =>
      select(treatmentTemplatesTable).get();

  Future<int> insertTemplate(TreatmentTemplatesTableCompanion t) =>
      into(treatmentTemplatesTable).insert(t);

  Future<bool> updateTemplate(TreatmentTemplatesTableCompanion t) =>
      update(treatmentTemplatesTable).replace(t);

  Future<int> deleteTemplate(int id) =>
      (delete(treatmentTemplatesTable)..where((t) => t.id.equals(id))).go();
}
