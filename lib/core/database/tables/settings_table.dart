import 'package:drift/drift.dart';

class SettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  String get tableName => 'settings';

  @override
  Set<Column> get primaryKey => {key};
}
