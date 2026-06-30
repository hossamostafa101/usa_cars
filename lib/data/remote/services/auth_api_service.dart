import 'package:dio/dio.dart';
import 'package:talabatfresh/core/constants/url_api.dart';
import 'package:talabatfresh/data/remote/api_client.dart';
import 'package:talabatfresh/models/auth_response_model.dart';
import 'package:talabatfresh/models/user_model.dart';

class AuthApiService {
  final ApiClient _apiClient = ApiClient();

  Future<AuthResponseModel> login({
    required String login,
    required String password,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.login,
      data: {
        'login': login,
        'password': password,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.registerCustomer,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> registerVendor({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String businessName,
    String? businessType,
    String? description,
    String? supportEmail,
    String? supportPhone,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.registerVendor,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'business_name': businessName,
        'business_type': businessType ?? 'multi_service_vendor',
        'description': description,
        'support_email': supportEmail,
        'support_phone': supportPhone,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  Future<UserModel?> me() async {
    final Response response = await _apiClient.get(UrlApi.me);

    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
      return UserModel.fromJson(body['data']);
    }

    return null;
  }

  Future<void> logout() async {
    await _apiClient.post(UrlApi.logout);
  }
}