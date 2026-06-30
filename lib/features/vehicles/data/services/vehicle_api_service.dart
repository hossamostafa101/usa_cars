import 'package:dio/dio.dart';
import 'package:talabatfresh/data/remote/api_client.dart';

import '../../../../core/constants/url_api.dart';
import '../models/vehicle_catalog_model.dart';
import '../models/vehicle_model.dart';

class VehicleApiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<VehicleModel>> getVehicles() async {
    final Response response = await _apiClient.get(UrlApi.vehicles);
    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<List<VehicleMakeModel>> getMakes() async {
    final Response response = await _apiClient.get(UrlApi.vehicleMakes);
    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleMakeModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<List<VehicleModelOption>> getModelsByMake(int makeId) async {
    final Response response = await _apiClient.get(
      UrlApi.vehicleModels,
      queryParameters: {
        'make_id': makeId,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleModelOption.fromJson)
          .toList();
    }

    return [];
  }

  Future<VehicleModel> createVehicle(Map<String, dynamic> data) async {
    final Response response = await _apiClient.post(
      UrlApi.vehicles,
      data: data,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return VehicleModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Failed to create vehicle.'
        : 'Failed to create vehicle.';
  }

  Future<VehicleModel> updateVehicle(
      int vehicleId,
      Map<String, dynamic> data,
      ) async {
    final Response response = await _apiClient.post(
      UrlApi.vehicleDetails(vehicleId),
      data: data,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return VehicleModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Failed to update vehicle.'
        : 'Failed to update vehicle.';
  }

  Future<void> setPrimaryVehicle(int vehicleId) async {
    await _apiClient.post(
      UrlApi.setPrimaryVehicle(vehicleId),
    );
  }

  Future<void> deleteVehicle(int vehicleId) async {
    await _apiClient.delete(
      UrlApi.vehicleDetails(vehicleId),
    );
  }
}