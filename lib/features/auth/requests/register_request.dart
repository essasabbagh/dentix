/// REGISTER REQUEST
class RegisterRequest {
  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.accepted,
    required this.password,
    required this.passwordConfirmation,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String accepted;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'accepted': accepted,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
