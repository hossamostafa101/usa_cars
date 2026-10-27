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

  /// GET /vehicle-catalog/years - returns a flat list of integer years.
  Future<List<int>> getYears() async {
    final Response response = await _apiClient.get(UrlApi.vehicleYears);
    final body = response.data;
    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .map((item) => int.tryParse(item.toString()))
          .whereType<int>()
      // VehicleController::store/update requires year >= 1996.
          .where((year) => year >= 1996 && year <= DateTime.now().year + 1)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));
    }
    throw const FormatException('Invalid vehicle years response.');
  }

  /// Existing callers may still call getMakes() without a year.
  Future<List<VehicleMakeModel>> getMakes({int? year}) async {
    final Response response = await _apiClient.get(
      UrlApi.vehicleMakes,
      queryParameters: {if (year != null) 'year': year},
    );
    final body = response.data;
    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleMakeModel.fromJson)
          .toList();
    }
    throw const FormatException('Invalid vehicle makes response.');
  }

  /// GET /vehicle-catalog/models?make_id=...&year=...
  /// Matches VehicleCatalogController::models and VehicleCatalogService::listModels.
  Future<List<VehicleModelOption>> getModelsByMake(
      int makeId, {
        int? year,
      }) async {
    final Response response = await _apiClient.get(
      UrlApi.vehicleModels,
      queryParameters: {
        'make_id': makeId,
        if (year != null) 'year': year,
      },
    );
    final body = response.data;
    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleModelOption.fromJson)
          .toList();
    }
    throw const FormatException('Invalid vehicle models response.');
  }

  Future<VehicleModel> createVehicle(Map<String, dynamic> data) async {
    final Response response = await _apiClient.post(UrlApi.vehicles, data: data);
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
    await _apiClient.post(UrlApi.setPrimaryVehicle(vehicleId));
  }

  Future<void> deleteVehicle(int vehicleId) async {
    await _apiClient.delete(UrlApi.vehicleDetails(vehicleId));
  }
}
