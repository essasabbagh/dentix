import 'package:drift/drift.dart';

class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get patientId => integer()();

  DateTimeColumn get appointmentDate => dateTime()();

  TextColumn get status => text()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
