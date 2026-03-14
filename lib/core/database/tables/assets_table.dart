import 'package:drift/drift.dart';
import 'patients_table.dart';
import 'treatments_table.dart';

class AssetsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // ── Owner (one of these is set, the other is null) ────────────────
  IntColumn get patientId => integer()
      .named('patient_id')
      .references(PatientsTable, #id, onDelete: KeyAction.cascade)
      .nullable()();

  IntColumn get treatmentId => integer()
      .named('treatment_id')
      .references(TreatmentsTable, #id, onDelete: KeyAction.cascade)
      .nullable()();

  // ── File metadata ─────────────────────────────────────────────────
  /// Original file name as shown to user  e.g. "xray_front.jpg"
  TextColumn get fileName => text().named('file_name')();

  /// Absolute path on disk  e.g. "/data/.../dentixflow/assets/uuid.jpg"
  TextColumn get filePath => text().named('file_path')();

  /// MIME type  e.g. "image/jpeg" | "application/pdf" | "image/png"
  TextColumn get mimeType => text().named('mime_type')();

  /// File size in bytes
  IntColumn get sizeBytes => integer().named('size_bytes')();

  /// Optional label  e.g. "صورة أشعة" / "تقرير طبي"
  TextColumn get label => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  String get tableName => 'assets';

  @override
  List<Index> get indexes => [
        Index('assets_patient_idx',
            'CREATE INDEX assets_patient_idx ON assets(patient_id)'),
        Index('assets_treatment_idx',
            'CREATE INDEX assets_treatment_idx ON assets(treatment_id)'),
      ];
}
