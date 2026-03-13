/// CONFIRM REGISTER CODE REQUEST
class ConfirmRegisterCodeRequest {
  ConfirmRegisterCodeRequest({
    required this.email,
    required this.verificationCode,
  });
  final String email;
  final String verificationCode;

  Map<String, dynamic> toJson() => {
    'email': email,
    'verification_code': verificationCode,
  };
}
