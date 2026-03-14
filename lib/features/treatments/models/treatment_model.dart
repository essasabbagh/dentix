import 'package:flutter/material.dart';

enum TreatmentStatus {
  planned,
  inProgress,
  completed,
  cancelled;

  String get arabicLabel {
    return switch (this) {
      TreatmentStatus.planned => 'مخطط',
      TreatmentStatus.inProgress => 'جارٍ',
      TreatmentStatus.completed => 'مكتمل',
      TreatmentStatus.cancelled => 'ملغي',
    };
  }

  Color statusColor(ThemeData t) {
    return switch (this) {
      TreatmentStatus.planned => t.colorScheme.primary,
      TreatmentStatus.inProgress => Colors.orange,
      TreatmentStatus.completed => Colors.green,
      TreatmentStatus.cancelled => Colors.red,
    };
  }

  String get dbValue {
    return switch (this) {
      TreatmentStatus.planned => 'planned',
      TreatmentStatus.inProgress => 'in_progress',
      TreatmentStatus.completed => 'completed',
      TreatmentStatus.cancelled => 'cancelled',
    };
  }

  static TreatmentStatus fromDb(String value) {
    return switch (value) {
      'in_progress' => TreatmentStatus.inProgress,
      'completed' => TreatmentStatus.completed,
      'cancelled' => TreatmentStatus.cancelled,
      _ => TreatmentStatus.planned,
    };
  }
}

class TreatmentModel {
  const TreatmentModel({
    required this.id,
    required this.patientId,
    this.appointmentId,
    required this.treatmentType,
    this.toothNumber,
    required this.price,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  final int id;
  final int patientId;
  final int? appointmentId;
  final String treatmentType;
  final int? toothNumber;
  final double price;
  final TreatmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TreatmentModel copyWith({
    int? id,
    int? patientId,
    int? appointmentId,
    String? treatmentType,
    int? toothNumber,
    double? price,
    TreatmentStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TreatmentModel(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    appointmentId: appointmentId ?? this.appointmentId,
    treatmentType: treatmentType ?? this.treatmentType,
    toothNumber: toothNumber ?? this.toothNumber,
    price: price ?? this.price,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
