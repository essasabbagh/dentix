class ResetHelper {
  ResetHelper({required this.email, required this.resetCode});

  /// Decode from a single string back into a ResetHelper
  factory ResetHelper.decode(String encoded) {
    final parts = encoded.split('|');
    if (parts.length != 2) {
      throw FormatException('Invalid encoded string: $encoded');
    }
    return ResetHelper(email: parts[0], resetCode: parts[1]);
  }
  final String email;
  final String resetCode;

  /// Encode both values into a single string
  String encode() {
    // You can customize the separator if you like
    return '$email|$resetCode';
  }

  /// Backup: return only the email
  String getEmail() => email;

  /// Backup: return only the code
  String getCode() => resetCode;
}
