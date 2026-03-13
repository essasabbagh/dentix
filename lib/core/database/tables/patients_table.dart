import 'package:drift/drift.dart';

class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get firstName => text()();

  TextColumn get lastName => text()();

  TextColumn get phone => text().nullable()();

  TextColumn get email => text().nullable()();

  TextColumn get gender => text().nullable()();

  DateTimeColumn get birthDate => dateTime().nullable()();

  TextColumn get address => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}