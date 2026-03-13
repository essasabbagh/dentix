import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/patients_table.dart';
import 'tables/appointments_table.dart';
import 'tables/treatments_table.dart';
import 'tables/payments_table.dart';
import 'tables/odontogram_table.dart';
import 'tables/settings_table.dart';

import 'daos/patients_dao.dart';
import 'daos/appointments_dao.dart';
import 'daos/treatments_dao.dart';
import 'daos/payments_dao.dart';
import 'daos/odontogram_dao.dart';
import 'daos/settings_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PatientsTable,
    AppointmentsTable,
    TreatmentsTable,
    PaymentsTable,
    OdontogramTable,
    SettingsTable,
  ],
  daos: [
    PatientsDao,
    AppointmentsDao,
    TreatmentsDao,
    PaymentsDao,
    OdontogramDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(DatabaseConnection connection) : super(connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Seed default settings
          await _seedDefaultSettings();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future migrations here
        },
      );

  Future<void> _seedDefaultSettings() async {
    final defaultSettings = {
      'clinic_name': 'عيادة الأسنان',
      'clinic_phone': '',
      'clinic_address': '',
      'currency': 'ر.س',
      'theme_mode': 'light',
      'language': 'ar',
      'doctor_name': 'الدكتور',
    };

    for (final entry in defaultSettings.entries) {
      await into(settingsTable).insertOnConflictUpdate(
        SettingsTableCompanion.insert(
          key: entry.key,
          value: entry.value,
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dentixflow.db'));
    return NativeDatabase.createInBackground(file);
  });
}
