/// UPDATE PASSWORD (AFTER RESET) REQUEST
class UpdatePasswordRequest {
  UpdatePasswordRequest({
    required this.email,
    required this.resetCode,
    required this.password,
    required this.passwordConfirmation,
  });
  final String email;
  final String resetCode;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() => {
    'email': email,
    'reset_code': resetCode,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}
