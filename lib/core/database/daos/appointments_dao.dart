import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/appointments_table.dart';
import '../tables/patients_table.dart';

part 'appointments_dao.g.dart';

/// Joined appointment with patient data
class AppointmentWithPatient {
  const AppointmentWithPatient(this.appointment, this.patient);
  final AppointmentsTableData appointment;
  final PatientsTableData patient;
}

@DriftAccessor(tables: [AppointmentsTable, PatientsTable])
class AppointmentsDao extends DatabaseAccessor<AppDatabase>
    with _$AppointmentsDaoMixin {
  AppointmentsDao(super.db);

  // ─── Queries ───────────────────────────────────────────────

  Future<List<AppointmentsTableData>> getAllAppointments() =>
      (select(appointmentsTable)..orderBy([
            (t) => OrderingTerm(
              expression: t.appointmentDate,
              mode: OrderingMode.desc,
            ),
          ]))
          .get();

  Stream<List<AppointmentsTableData>> watchAllAppointments() =>
      (select(appointmentsTable)..orderBy([
            (t) => OrderingTerm(
              expression: t.appointmentDate,
              mode: OrderingMode.desc,
            ),
          ]))
          .watch();

  /// Appointments for a specific date (local day boundaries)
  Future<List<AppointmentWithPatient>> getAppointmentsForDate(
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final query =
        select(appointmentsTable).join([
            innerJoin(
              patientsTable,
              patientsTable.id.equalsExp(appointmentsTable.patientId),
            ),
          ])
          ..where(
            appointmentsTable.appointmentDate.isBiggerOrEqualValue(start) &
                appointmentsTable.appointmentDate.isSmallerThanValue(end),
          )
          ..orderBy([
            OrderingTerm(expression: appointmentsTable.appointmentDate),
          ]);

    final rows = await query.get();
    return rows
        .map(
          (row) => AppointmentWithPatient(
            row.readTable(appointmentsTable),
            row.readTable(patientsTable),
          ),
        )
        .toList();
  }

  Stream<List<AppointmentWithPatient>> watchAppointmentsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final query =
        select(appointmentsTable).join([
            innerJoin(
              patientsTable,
              patientsTable.id.equalsExp(appointmentsTable.patientId),
            ),
          ])
          ..where(
            appointmentsTable.appointmentDate.isBiggerOrEqualValue(start) &
                appointmentsTable.appointmentDate.isSmallerThanValue(end),
          )
          ..orderBy([
            OrderingTerm(expression: appointmentsTable.appointmentDate),
          ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => AppointmentWithPatient(
              row.readTable(appointmentsTable),
              row.readTable(patientsTable),
            ),
          )
          .toList(),
    );
  }

  /// Appointments for a patient
  Stream<List<AppointmentsTableData>> watchPatientAppointments(int patientId) =>
      (select(appointmentsTable)
            ..where((t) => t.patientId.equals(patientId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.appointmentDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  /// Today's appointment count
  Future<int> getTodayAppointmentsCount() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final count = appointmentsTable.id.count();
    final query = selectOnly(appointmentsTable)
      ..addColumns([count])
      ..where(
        appointmentsTable.appointmentDate.isBiggerOrEqualValue(start) &
            appointmentsTable.appointmentDate.isSmallerThanValue(end),
      );

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<AppointmentsTableData?> getAppointmentById(int id) => (select(
    appointmentsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  // ─── Mutations ─────────────────────────────────────────────

  Future<int> insertAppointment(AppointmentsTableCompanion appt) =>
      into(appointmentsTable).insert(appt);

  Future<bool> updateAppointment(AppointmentsTableCompanion appt) =>
      update(appointmentsTable).replace(appt);

  Future<void> updateStatus(int id, String status) =>
      (update(appointmentsTable)..where((t) => t.id.equals(id))).write(
        AppointmentsTableCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> deleteAppointment(int id) =>
      (delete(appointmentsTable)..where((t) => t.id.equals(id))).go();
}
