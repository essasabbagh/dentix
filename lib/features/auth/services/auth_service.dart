import 'package:dio/dio.dart';

import 'package:template/core/client/client.dart';
import 'package:template/core/errors/error_handler.dart';

import '../models/auth_model.dart';
import '../models/register_response.dart';
import '../models/user_data.dart';
import '../requests/requests.dart';

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  /// LOGIN
  Future<AuthModel> login(LoginRequest val) async {
    try {
      final data = FormData.fromMap(val.toJson());
      final res = await _client.post('/login', data: data);
      return AuthModel.fromJson(res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// REGISTER
  Future<RegisterResponse> register(RegisterRequest val) async {
    try {
      final data = FormData.fromMap(val.toJson());
      final res = await _client.post('/register', data: data);

      return RegisterResponse.fromJson(res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// CONFIRM REGISTER CODE
  Future<void> confirmRegisterCode(ConfirmRegisterCodeRequest val) async {
    try {
      final data = FormData.fromMap(val.toJson());
      await _client.post('/confirm-register-code', data: data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// RESET PASSWORD
  Future<void> resetPassword(ResetPasswordRequest val) async {
    try {
      final data = FormData.fromMap(val.toJson());
      await _client.post('/reset-password', data: data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// CONFIRM RESET PASSWORD CODE
  Future<void> confirmResetPasswordCode(
    ConfirmResetPasswordCodeRequest val,
  ) async {
    try {
      final data = FormData.fromMap(val.toJson());
      await _client.post('/confirm-reset-password-code', data: data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// UPDATE PASSWORD (after reset)
  Future<void> updatePassword(UpdatePasswordRequest val) async {
    try {
      final data = FormData.fromMap(val.toJson());
      await _client.post('/update-password', data: data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// REFRESH TOKEN (auth required)
  Future<AuthModel> refreshToken() async {
    try {
      final res = await _client.post('/refresh-token');
      return AuthModel.fromJson(res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// LOGOUT (auth required)
  Future<void> logout() async {
    try {
      await _client.post('/logout');
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// GET PROFILE (auth required)
  Future<UserData> getProfile() async {
    try {
      final res = await _client.get('/profile');
      return UserData.fromJson(res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<AuthModel> socialLogin(String idToken, String accesstoken) async {
    try {
      final res = await _client.post(
        '/auth/google/mobile',
        data: {'id_token': idToken, 'access_token': accesstoken},
      );

      return AuthModel.fromJson(res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
