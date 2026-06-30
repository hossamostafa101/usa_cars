import 'user_model.dart';

class AuthResponseModel {
  final bool status;
  final String message;
  final UserModel? user;
  final String? token;
  final String? tokenType;
  final int? expiresIn;

  const AuthResponseModel({
    required this.status,
    required this.message,
    this.user,
    this.token,
    this.tokenType,
    this.expiresIn,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return AuthResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      user: data is Map<String, dynamic> && data['user'] is Map<String, dynamic>
          ? UserModel.fromJson(data['user'])
          : data is Map<String, dynamic>
          ? UserModel.fromJson(data)
          : null,
      token: data is Map<String, dynamic> ? data['token']?.toString() : null,
      tokenType:
      data is Map<String, dynamic> ? data['token_type']?.toString() : null,
      expiresIn: data is Map<String, dynamic>
          ? int.tryParse(data['expires_in']?.toString() ?? '')
          : null,
    );
  }
}