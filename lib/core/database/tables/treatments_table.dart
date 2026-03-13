import 'package:drift/drift.dart';

class Treatments extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get patientId => integer()();

  TextColumn get treatmentType => text()();

  RealColumn get price => real()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
