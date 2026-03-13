class UserData {
  UserData({
    this.id,
    this.firstName,
    this.lastName,
    this.userName,
    this.email,
    this.phoneNumber,
    this.image,
    this.bio,
    this.address,
    this.licenseNumber,
    this.licenseFile,
    this.emailVerified,
    this.emailVerifiedAt,
    this.isActive,
    this.verificationCode,
    this.google2FaSecret,
    this.google2FaEnabled,
    this.googleId,
    this.accountType,
    this.createdAt,
    this.updatedAt,
    this.socialMedia,
    this.shamcash,
    this.gender,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['id'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    userName: json['user_name'],
    email: json['email'],
    phoneNumber: json['phone_number'],
    image: json['image'],
    bio: json['bio'],
    emailVerified: json['email_verified'],
    emailVerifiedAt: json['email_verified_at'] == null
        ? null
        : DateTime.parse(json['email_verified_at']),
    isActive: json['is_active'],
    verificationCode: json['verification_code'],
    google2FaSecret: json['google2fa_secret'],
    google2FaEnabled: json['google2fa_enabled'],
    googleId: json['google_id'],
    accountType: json['account_type'],
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] == null
        ? null
        : DateTime.parse(json['updated_at']),
    socialMedia: (json['social_media'] as List<dynamic>?)
        ?.map((e) => SocialMedia.fromJson(e as Map<String, dynamic>))
        .toList(),
    shamcash: json['shamcash_image'],
    gender: json['gender'],
  );
  
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? userName;
  final String? email;
  final String? phoneNumber;
  final String? image;
  final String? bio;
  final String? address;
  final String? licenseNumber;
  final String? licenseFile;
  final int? emailVerified;
  final DateTime? emailVerifiedAt;
  final int? isActive;
  final dynamic verificationCode;
  final dynamic google2FaSecret;
  final int? google2FaEnabled;
  final dynamic googleId;
  final String? accountType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<SocialMedia>? socialMedia;
  final String? shamcash;
  final String? gender;

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'user_name': userName,
    'email': email,
    'phone_number': phoneNumber,
    'image': image,
    'bio': bio,
    'address': address,
    'license_number': licenseNumber,
    'license_file': licenseFile,
    'email_verified': emailVerified,
    'email_verified_at': emailVerifiedAt?.toIso8601String(),
    'is_active': isActive,
    'verification_code': verificationCode,
    'google2fa_secret': google2FaSecret,
    'google2fa_enabled': google2FaEnabled,
    'google_id': googleId,
    'account_type': accountType,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'social_media': socialMedia,
  };
}

class SocialMedia {
  SocialMedia({
    this.id,
    this.customerId,
    this.platform,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      id: json['id'],
      customerId: json['customer_id'],
      platform: json['platform'],
      value: json['value'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
  final int? id;
  final int? customerId;
  final String? platform;
  final String? value;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
