/// CHANGE PASSWORD REQUEST (AUTH REQUIRED)
class ChangePasswordRequest {
  ChangePasswordRequest({
    required this.oldPassword,
    required this.password,
    required this.passwordConfirmation,
  });
  
  final String oldPassword;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() => {
    'old_password': oldPassword,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}
