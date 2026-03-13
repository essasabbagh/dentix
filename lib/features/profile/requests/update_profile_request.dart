import 'package:dio/dio.dart';

/// UPDATE PROFILE REQUEST
class UpdateProfileRequest {
  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.gender,
    this.phoneNumber,
    this.emailAddress,
    this.profileImage,
    this.licenseFile,
    this.shamCash,
  });

  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? phoneNumber;
  final String? emailAddress;

  /// Files
  final MultipartFile? profileImage;
  final MultipartFile? licenseFile;
  final MultipartFile? shamCash;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (firstName != null) map['first_name'] = firstName;
    if (lastName != null) map['last_name'] = lastName;
    if (gender != null) map['gender'] = gender;
    if (phoneNumber != null) map['phone_number'] = phoneNumber;
    if (emailAddress != null) map['emailaddress'] = emailAddress;
    if (profileImage != null) map['profile_image'] = profileImage;

    return map;
  }

  /// Convert to FormData for Dio
  Future<FormData> toFormData() async {
    final formData = FormData();

    if (firstName != null) {
      formData.fields.add(MapEntry('first_name', firstName!));
    }
    if (lastName != null) {
      formData.fields.add(MapEntry('last_name', lastName!));
    }
    if (gender != null) {
      formData.fields.add(MapEntry('gender', gender!));
    }
    if (phoneNumber != null) {
      formData.fields.add(MapEntry('phone_number', phoneNumber!));
    }
    if (emailAddress != null) {
      formData.fields.add(MapEntry('email_address', emailAddress!));
    }
    if (profileImage != null) {
      formData.files.add(MapEntry('profile_image', profileImage!));
    }

    return formData;
  }
}
