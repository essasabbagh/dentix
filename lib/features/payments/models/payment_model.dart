enum PaymentMethod {
  cash,
  card,
  transfer;

  String get arabicLabel {
    switch (this) {
      case PaymentMethod.cash:
        return 'نقد';
      case PaymentMethod.card:
        return 'بطاقة';
      case PaymentMethod.transfer:
        return 'تحويل';
    }
  }

  String get dbValue {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.transfer:
        return 'transfer';
    }
  }

  static PaymentMethod fromDb(String value) {
    switch (value) {
      case 'card':
        return PaymentMethod.card;
      case 'transfer':
        return PaymentMethod.transfer;
      default:
        return PaymentMethod.cash;
    }
  }
}

enum PaymentStatus {
  paid,
  pending,
  partial;

  String get arabicLabel {
    switch (this) {
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.pending:
        return 'معلق';
      case PaymentStatus.partial:
        return 'جزئي';
    }
  }

  String get dbValue {
    switch (this) {
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.partial:
        return 'partial';
    }
  }

  static PaymentStatus fromDb(String value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'partial':
        return PaymentStatus.partial;
      default:
        return PaymentStatus.paid;
    }
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
