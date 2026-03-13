import 'user_data.dart';

class AuthModel {
  AuthModel({this.status, this.message, this.data, this.token});

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    status: json['status'],
    message: json['message'],
    data: json['data'] == null ? null : UserData.fromJson(json['data']),
    token: json['token'],
  );
  bool? status;
  String? message;
  UserData? data;
  String? token;

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
    'token': token,
  };
}
