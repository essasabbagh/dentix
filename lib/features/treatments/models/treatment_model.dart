enum TreatmentStatus {
  planned,
  inProgress,
  completed,
  cancelled;

  String get arabicLabel {
    switch (this) {
      case TreatmentStatus.planned:
        return 'مخطط';
      case TreatmentStatus.inProgress:
        return 'جارٍ';
      case TreatmentStatus.completed:
        return 'مكتمل';
      case TreatmentStatus.cancelled:
        return 'ملغي';
    }
  }

  String get dbValue {
    switch (this) {
      case TreatmentStatus.planned:
        return 'planned';
      case TreatmentStatus.inProgress:
        return 'in_progress';
      case TreatmentStatus.completed:
        return 'completed';
      case TreatmentStatus.cancelled:
        return 'cancelled';
    }
  }

  static TreatmentStatus fromDb(String value) {
    switch (value) {
      case 'in_progress':
        return TreatmentStatus.inProgress;
      case 'completed':
        return TreatmentStatus.completed;
      case 'cancelled':
        return TreatmentStatus.cancelled;
      default:
        return TreatmentStatus.planned;
    }
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
