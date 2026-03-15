// Rebuild trigger
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
import 'tables/assets_table.dart';
import 'tables/treatment_templates_table.dart';

import 'daos/patients_dao.dart';
import 'daos/appointments_dao.dart';
import 'daos/treatments_dao.dart';
import 'daos/payments_dao.dart';
import 'daos/odontogram_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/assets_dao.dart';
import 'daos/reports_dao.dart';
import 'daos/treatment_templates_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PatientsTable,
    AppointmentsTable,
    TreatmentsTable,
    PaymentsTable,
    OdontogramTable,
    SettingsTable,
    AssetsTable,
    TreatmentTemplatesTable,
  ],
  daos: [
    PatientsDao,
    AppointmentsDao,
    TreatmentsDao,
    PaymentsDao,
    OdontogramDao,
    SettingsDao,
    AssetsDao,
    ReportsDao,
    TreatmentTemplatesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDefaultSettings();
      await _seedDefaultTreatmentTemplates();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(assetsTable);
      }
      if (from < 3) {
        await m.createTable(treatmentTemplatesTable);
        await _seedDefaultTreatmentTemplates();
      }
    },
  );

  Future<void> _seedDefaultTreatmentTemplates() async {
    final commonTreatments = [
      'فحص',
      'تنظيف وتلميع',
      'حشوة ضوئية',
      'سحب عصب',
      'قلع',
      'تلبيسة',
      'جسر',
      'طقم أسنان',
      'تقويم أسنان',
      'زراعة أسنان',
    ];
    for (final name in commonTreatments) {
      await into(treatmentTemplatesTable).insertOnConflictUpdate(
        TreatmentTemplatesTableCompanion.insert(
          name: name,
          defaultPrice: const Value(0.0),
        ),
      );
    }
  }

  Future<void> _seedDefaultSettings() async {
    final defaultSettings = {
      'clinic_name': 'عيادة الأسنان',
      'clinic_phone': '',
      'clinic_address': '',
      'currency': '₺',
      'theme_mode': 'light',
      'language': 'ar',
      'doctor_name': 'الدكتور',
    };
    for (final entry in defaultSettings.entries) {
      await into(settingsTable).insertOnConflictUpdate(
        SettingsTableCompanion.insert(key: entry.key, value: entry.value),
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
