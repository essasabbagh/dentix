import 'package:drift/drift.dart';
import 'patients_table.dart';

class OdontogramTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId =>
      integer().named('patient_id').references(PatientsTable, #id)();
  IntColumn get toothNumber => integer().named('tooth_number')();
  // 1-32
  TextColumn get condition =>
      text().withDefault(const Constant('healthy'))();
  // healthy | decay | missing | filled | crown | implant | root_canal
  TextColumn get treatmentType => text().named('treatment_type').nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  String get tableName => 'odontogram';

  @override
  List<Set<Column>> get uniqueKeys => [
        {patientId, toothNumber}
      ];
}
