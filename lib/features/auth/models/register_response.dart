class RegisterResponse {
  RegisterResponse({this.message, this.userId, this.email});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        message: json['message'],
        userId: json['user_id'],
        email: json['email'],
      );
  final String? message;
  final int? userId;
  final String? email;
}
