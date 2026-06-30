import '../../../../core/enums/account_type.dart';

class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final AccountType accountType;
  final String? status;
  final String? profileImage;
  final VendorProfileModel? vendorProfile;
  final UserProfileModel? userProfile;

  const UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.accountType = AccountType.unknown,
    this.status,
    this.profileImage,
    this.vendorProfile,
    this.userProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserModel();

    return UserModel(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      accountType: AccountType.fromString(
        json['user_type']?.toString(),
      ),
      status: json['status']?.toString(),
      profileImage: json['profile_image']?.toString(),
      vendorProfile: json['vendor_profile'] is Map<String, dynamic>
          ? VendorProfileModel.fromJson(json['vendor_profile'])
          : null,
      userProfile: json['user_profile'] is Map<String, dynamic>
          ? UserProfileModel.fromJson(json['user_profile'])
          : null,
    );
  }

  bool get isCustomer => accountType == AccountType.customer;
  bool get isVendor => accountType == AccountType.vendor;
  bool get isAdmin => accountType == AccountType.admin;

  bool get isActive => status == 'active';
  bool get isPendingVerification => status == 'pending_verification';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': accountType.value,
      'status': status,
      'profile_image': profileImage,
      'vendor_profile': vendorProfile?.toJson(),
      'user_profile': userProfile?.toJson(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class UserProfileModel {
  final int? id;
  final int? userId;
  final String? dateOfBirth;
  final String? gender;
  final String? preferredLanguage;

  const UserProfileModel({
    this.id,
    this.userId,
    this.dateOfBirth,
    this.gender,
    this.preferredLanguage,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      preferredLanguage: json['preferred_language']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'preferred_language': preferredLanguage,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class VendorProfileModel {
  final int? id;
  final int? userId;
  final String? businessName;
  final String? businessType;
  final String? verificationStatus;
  final bool isVerified;
  final String? description;
  final String? supportEmail;
  final String? supportPhone;

  const VendorProfileModel({
    this.id,
    this.userId,
    this.businessName,
    this.businessType,
    this.verificationStatus,
    this.isVerified = false,
    this.description,
    this.supportEmail,
    this.supportPhone,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    return VendorProfileModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      businessName: json['business_name']?.toString(),
      businessType: json['business_type']?.toString(),
      verificationStatus: json['verification_status']?.toString(),
      isVerified: json['is_verified'] == true ||
          json['is_verified'] == 1 ||
          json['is_verified'] == '1',
      description: json['description']?.toString(),
      supportEmail: json['support_email']?.toString(),
      supportPhone: json['support_phone']?.toString(),
    );
  }

  bool get isApproved => verificationStatus == 'approved';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'business_type': businessType,
      'verification_status': verificationStatus,
      'is_verified': isVerified,
      'description': description,
      'support_email': supportEmail,
      'support_phone': supportPhone,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}