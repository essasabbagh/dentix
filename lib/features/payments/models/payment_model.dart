enum PaymentMethod {
  cash,
  card,
  transfer;

  String get arabicLabel {
    return switch (this) {
      PaymentMethod.cash => 'نقد',
      PaymentMethod.card => 'بطاقة',
      PaymentMethod.transfer => 'تحويل',
    };
  }

  String get dbValue {
    return switch (this) {
      PaymentMethod.cash => 'cash',
      PaymentMethod.card => 'card',
      PaymentMethod.transfer => 'transfer',
    };
  }

  static PaymentMethod fromDb(String value) {
    return switch (value) {
      'card' => PaymentMethod.card,
      'transfer' => PaymentMethod.transfer,
      _ => PaymentMethod.cash,
    };
  }
}

enum PaymentStatus {
  paid,
  pending,
  partial;

  String get arabicLabel {
    return switch (this) {
      PaymentStatus.paid => 'مدفوع',
      PaymentStatus.pending => 'معلق',
      PaymentStatus.partial => 'جزئي',
    };
  }

  String get dbValue {
    return switch (this) {
      PaymentStatus.paid => 'paid',
      PaymentStatus.pending => 'pending',
      PaymentStatus.partial => 'partial',
    };
  }

  static PaymentStatus fromDb(String value) {
    return switch (value) {
      'pending' => PaymentStatus.pending,
      'partial' => PaymentStatus.partial,
      _ => PaymentStatus.paid,
    };
  }
}

class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.patientId,
    this.treatmentId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
  });
  final int id;
  final int patientId;
  final int? treatmentId;
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;
}
