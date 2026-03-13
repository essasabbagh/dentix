class LoginRequest {
  LoginRequest({this.email, this.password, this.fcmToken});

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    email: json['email'],
    password: json['password'],
    fcmToken: json['fcm_token'],
  );

  String? email;
  String? password;
  String? fcmToken;

  Map<String, dynamic> toJson() => {
    'email_or_serial_number': email,
    'password': password,
    // TODO add fcm token
    // 'fcm_token': fcmToken,
  };
}
