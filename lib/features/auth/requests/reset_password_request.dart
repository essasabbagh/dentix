/// RESET PASSWORD REQUEST
class ResetPasswordRequest {
  ResetPasswordRequest({required this.email});
  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}
