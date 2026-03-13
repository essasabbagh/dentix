import '../../patients/models/patient_model.dart';

enum AppointmentStatus {
  scheduled,
  completed,
  cancelled,
  noShow;

  String get arabicLabel {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'مجدول';
      case AppointmentStatus.completed:
        return 'مكتمل';
      case AppointmentStatus.cancelled:
        return 'ملغي';
      case AppointmentStatus.noShow:
        return 'لم يحضر';
    }
  }

  String get dbValue {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'scheduled';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.noShow:
        return 'no_show';
    }
  }

  static AppointmentStatus fromDb(String value) {
    switch (value) {
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no_show':
        return AppointmentStatus.noShow;
      default:
        return AppointmentStatus.scheduled;
    }
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
