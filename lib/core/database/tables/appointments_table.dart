import 'package:drift/drift.dart';
import 'patients_table.dart';

class AppointmentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId =>
      integer().named('patient_id').references(PatientsTable, #id)();
  DateTimeColumn get appointmentDate => dateTime().named('appointment_date')();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  // status: scheduled | completed | cancelled | no_show
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  String get tableName => 'appointments';

  @override
  List<Index> get indexes => [
    Index(
      'appt_date_idx',
      'CREATE INDEX appt_date_idx ON appointments(appointment_date)',
    ),
    Index(
      'appt_patient_idx',
      'CREATE INDEX appt_patient_idx ON appointments(patient_id)',
    ),
  ];
}
