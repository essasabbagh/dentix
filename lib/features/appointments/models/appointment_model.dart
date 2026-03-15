import 'package:flutter/material.dart';

import 'package:template/features/patients/models/patient_model.dart';
import 'package:template/features/treatments/models/treatment_model.dart';

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

  Color get statusColor {
    return switch (this) {
      AppointmentStatus.scheduled => Colors.blue,
      AppointmentStatus.completed => Colors.green,
      AppointmentStatus.cancelled => Colors.red,
      AppointmentStatus.noShow => Colors.orange,
    };
  }
}

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.appointmentDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.patient,
    this.treatments = const [],
  });
  final int id;
  final int patientId;
  final DateTime appointmentDate;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optionally joined patient
  final PatientModel? patient;

  // List of associated treatments
  final List<TreatmentModel> treatments;

  String get timeLabel {
    final h = appointmentDate.hour.toString().padLeft(2, '0');
    final m = appointmentDate.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String generateWhatsAppMessage() {
    final patientName = patient?.fullName ?? 'عزيزي المريض';
    final dateStr =
        '${appointmentDate.year}/${appointmentDate.month}/${appointmentDate.day}';
    final timeStr = timeLabel;

    return switch (status) {
      AppointmentStatus.scheduled =>
        'مرحباً $patientName،\n'
            'نود تذكيرك بموعدك القادم في عيادة الأسنان:\n'
            'التاريخ: $dateStr\n'
            'الوقت: $timeStr\n'
            'نتمنى لك يوماً سعيداً.',
      AppointmentStatus.completed =>
        'مرحباً $patientName،\n'
            'شكراً لزيارتك لنا اليوم. نتمنى أن تكون راضياً عن الخدمة المقدمة.\n'
            'في حال وجود أي استفسار، لا تتردد في التواصل معنا.',
      AppointmentStatus.cancelled =>
        'مرحباً $patientName،\n'
            'تم إلغاء موعدك المحدد بتاريخ $dateStr الساعة $timeStr.\n'
            'إذا كنت ترغب في تحديد موعد جديد، يرجى التواصل معنا.',
      AppointmentStatus.noShow =>
        'مرحباً $patientName،\n'
            'لقد فاتك موعدك اليوم ($dateStr الساعة $timeStr).\n'
            'يرجى التواصل معنا لإعادة جدولة الموعد إذا كنت لا تزال بحاجة للخدمة.',
    };
  }

  AppointmentModel copyWith({
    int? id,
    int? patientId,
    DateTime? appointmentDate,
    AppointmentStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    PatientModel? patient,
    List<TreatmentModel>? treatments,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patient: patient ?? this.patient,
      treatments: treatments ?? this.treatments,
    );
  }
}
