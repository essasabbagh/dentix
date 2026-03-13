import 'package:drift/drift.dart';

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get patientId => integer()();

  RealColumn get amount => real()();

  TextColumn get method => text()();

  DateTimeColumn get paymentDate => dateTime()();

  TextColumn get notes => text().nullable()();
}
