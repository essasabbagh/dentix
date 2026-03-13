import 'package:drift/drift.dart';

class PatientsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text().named('first_name')();
  TextColumn get lastName => text().named('last_name')();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get gender => text().nullable()(); // male, female
  DateTimeColumn get birthDate => dateTime().named('birth_date').nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  String get tableName => 'patients';

  @override
  List<Set<Column>> get uniqueKeys => [
    {phone},
  ];

  @override
  List<Index> get indexes => [
    Index(
      'patients_phone_idx',
      'CREATE INDEX patients_phone_idx ON patients(phone)',
    ),
    Index(
      'patients_last_name_idx',
      'CREATE INDEX patients_last_name_idx ON patients(last_name)',
    ),
  ];
}
