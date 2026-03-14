class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.patientId,
    this.treatmentId,
    required this.amount,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
  });
  final int id;
  final int patientId;
  final int? treatmentId;
  final double amount;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;
}
