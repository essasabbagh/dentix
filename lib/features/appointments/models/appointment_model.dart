import 'package:template/features/patients/models/patient_model.dart';

enum AppointmentStatus {
  scheduled,
  completed,
  cancelled,
  noShow;

  String get arabicLabel {
    return switch (this) {
      AppointmentStatus.scheduled => 'مجدول',
      AppointmentStatus.completed => 'مكتمل',
      AppointmentStatus.cancelled => 'ملغي',
      AppointmentStatus.noShow => 'لم يحضر',
    };
  }

  String get dbValue {
    return switch (this) {
      AppointmentStatus.scheduled => 'scheduled',
      AppointmentStatus.completed => 'completed',
      AppointmentStatus.cancelled => 'cancelled',
      AppointmentStatus.noShow => 'no_show',
    };
  }

  static AppointmentStatus fromDb(String value) {
    return switch (value) {
      'completed' => AppointmentStatus.completed,
      'cancelled' => AppointmentStatus.cancelled,
      'no_show' => AppointmentStatus.noShow,
      _ => AppointmentStatus.scheduled,
    };
  }
}

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.appointmentDate,
    required this.status,
    required this.doctorName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.patient,
  });
  final int id;
  final int patientId;
  final DateTime appointmentDate;
  final AppointmentStatus status;
  final String doctorName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optionally joined patient
  final PatientModel? patient;

  String get timeLabel {
    final h = appointmentDate.hour.toString().padLeft(2, '0');
    final m = appointmentDate.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  AppointmentModel copyWith({
    int? id,
    int? patientId,
    DateTime? appointmentDate,
    AppointmentStatus? status,
    String? doctorName,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    PatientModel? patient,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      status: status ?? this.status,
      doctorName: doctorName ?? this.doctorName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patient: patient ?? this.patient,
    );
  }
}
