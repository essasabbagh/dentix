/// Domain model for Patient - wraps generated Drift data class
/// with computed helpers for Arabic display
class PatientModel {
  const PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.gender,
    this.birthDate,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? gender;
  final DateTime? birthDate;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Full name Arabic display
  String get fullName => '$firstName $lastName';

  /// Age calculated from birth date
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Arabic gender label
  String get genderLabel {
    switch (gender) {
      case 'male':
        return 'ذكر';
      case 'female':
        return 'أنثى';
      default:
        return 'غير محدد';
    }
  }

  PatientModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? gender,
    DateTime? birthDate,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
