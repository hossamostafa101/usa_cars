import 'package:dio/dio.dart';
import 'package:talabatfresh/data/remote/api_client.dart';
import 'package:talabatfresh/models/user_model.dart';

import '../../../../core/constants/url_api.dart';
import '../../../vehicles/data/models/vehicle_model.dart';

class ProfileApiService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel?> getProfile() async {
    final Response response = await _apiClient.get(
      UrlApi.profile,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return UserModel.fromJson(body['data']);
    }

    return null;
  }

  Future<List<VehicleModel>> getVehicles() async {
    final Response response = await _apiClient.get(
      UrlApi.vehicles,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.updateProfile,
      data: {
        'name': name.trim(),
        if (phone != null)
          'phone': phone.trim(),
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true) {
      return;
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to update profile.'
        : 'Failed to update profile.';
  }

  Future<void> updateCustomerProfile({
    String? dateOfBirth,
    String? gender,
    String? preferredLanguage,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.updateCustomerProfile,
      data: {
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'preferred_language':
        preferredLanguage,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true) {
      return;
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to update customer profile.'
        : 'Failed to update customer profile.';
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.changePassword,
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation':
        passwordConfirmation,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true) {
      return;
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to change password.'
        : 'Failed to change password.';
  }
}