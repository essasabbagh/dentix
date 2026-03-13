/// CONFIRM RESET PASSWORD CODE REQUEST
class ConfirmResetPasswordCodeRequest {
  ConfirmResetPasswordCodeRequest({
    required this.email,
    required this.resetCode,
  });
  final String email;
  final String resetCode;

  Map<String, dynamic> toJson() => {'email': email, 'reset_code': resetCode};
}
