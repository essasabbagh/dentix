import 'package:drift/drift.dart';
import 'patients_table.dart';
import 'appointments_table.dart';

class TreatmentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId =>
      integer().named('patient_id').references(PatientsTable, #id)();
  IntColumn get appointmentId => integer()
      .named('appointment_id')
      .references(AppointmentsTable, #id)
      .nullable()();
  TextColumn get treatmentType => text().named('treatment_type')();
  IntColumn get toothNumber => integer().named('tooth_number').nullable()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  TextColumn get status =>
      text().withDefault(const Constant('planned'))();
  // planned | in_progress | completed | cancelled
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  String get tableName => 'treatments';
}
