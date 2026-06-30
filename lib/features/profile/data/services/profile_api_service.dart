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
}