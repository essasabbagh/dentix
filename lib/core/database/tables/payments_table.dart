import 'package:drift/drift.dart';
import 'patients_table.dart';
import 'treatments_table.dart';

class PaymentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId =>
      integer().named('patient_id').references(PatientsTable, #id)();
  IntColumn get treatmentId => integer()
      .named('treatment_id')
      .references(TreatmentsTable, #id)
      .nullable()();
  RealColumn get amount => real()();
  // paid | pending | partial
  DateTimeColumn get paymentDate =>
      dateTime().named('payment_date').withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  String get tableName => 'payments';
}
