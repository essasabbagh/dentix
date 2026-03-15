import 'package:drift/drift.dart';

class TreatmentTemplatesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  RealColumn get defaultPrice => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  String get tableName => 'treatment_templates';
}
