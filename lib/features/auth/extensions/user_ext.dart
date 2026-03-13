import '../models/user_data.dart';

extension UserExt on UserData {
  String get fullName => '$firstName $lastName';

  String get formattedPhoneNumber {
    if (phoneNumber == null || phoneNumber!.isEmpty) return '';
    final number = phoneNumber!.trim();
    if (number.startsWith('9')) {
      return '+963$number';
    }
    return number;
  }
}
