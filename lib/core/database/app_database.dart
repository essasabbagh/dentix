import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'database_initializer.dart';
import 'tables/appointments_table.dart';
import 'tables/patients_table.dart';
import 'tables/payments_table.dart';
import 'tables/settings_table.dart';
import 'tables/treatments_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Patients,
    Appointments,
    Treatments,
    Payments,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final File file = await DatabaseInitializer.getDatabaseFile();
    return NativeDatabase(file);
  });
}