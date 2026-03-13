import 'package:dio/dio.dart';

import 'package:template/core/client/client.dart';
import 'package:template/core/errors/error_handler.dart';
import 'package:template/features/auth/models/user_data.dart';

import '../requests/change_password_request.dart';
import '../requests/update_profile_request.dart';

class ProfileService {
  ProfileService(this._client);

  final ApiClient _client;

  /// UPDATE PROFILE (auth required)
  Future<UserData> updateProfile(UpdateProfileRequest val) async {
    try {
      final data = FormData.fromMap(val.toJson());
      final res = await _client.post('/profile', data: data);
      return UserData.fromJson(res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// DELETE PROFILE (auth required)
  Future<void> deleteProfile() async {
    try {
      await _client.delete('/profile');
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// CHANGE PASSWORD (auth required)
  Future<void> changePassword(ChangePasswordRequest val) async {
    try {
      final data = FormData.fromMap(val.toJson());
      await _client.post('/change-password', data: data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
