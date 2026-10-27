import 'package:dio/dio.dart';
import 'package:talabatfresh/data/remote/api_client.dart';

import '../../../../core/constants/url_api.dart';
import '../models/roadside_model.dart';

class RoadsideApiService {
  final ApiClient _apiClient = ApiClient();

  Future<RoadsideHomeModel> getHome() async {
    final Response response = await _apiClient.get(
      UrlApi.roadsideHome,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return RoadsideHomeModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Failed to load roadside home.'
        : 'Failed to load roadside home.';
  }

  Future<List<RoadsideServiceModel>> getServices() async {
    final Response response = await _apiClient.get(
      UrlApi.roadsideServices,
    );

    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RoadsideServiceModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<List<RoadsideRequestModel>> getRequests() async {
    final Response response = await _apiClient.get(
      UrlApi.roadsideRequests,
    );

    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RoadsideRequestModel.fromJson)
          .toList();
    }

    return [];
  }


  Future<RoadsideRequestModel>
  createRequest({
    required int roadsideServiceId,
    required int vehicleId,

    int? branchId,

    required double latitude,
    required double longitude,

    String? locationAddress,

    String? destinationAddress,
    double? destinationLatitude,
    double? destinationLongitude,

    String? notes,
  }) async {
    final response =
    await _apiClient.post(
      UrlApi.roadsideRequests,
      data: {
        'roadside_service_id':
        roadsideServiceId,

        'vehicle_id':
        vehicleId,

        if (branchId != null)
          'branch_id':
          branchId,

        'latitude':
        latitude,

        'longitude':
        longitude,

        if (locationAddress != null &&
            locationAddress
                .trim()
                .isNotEmpty)
          'location_address':
          locationAddress.trim(),

        if (destinationAddress != null &&
            destinationAddress
                .trim()
                .isNotEmpty)
          'destination_address':
          destinationAddress.trim(),

        if (destinationLatitude != null)
          'destination_latitude':
          destinationLatitude,

        if (destinationLongitude != null)
          'destination_longitude':
          destinationLongitude,

        if (notes != null &&
            notes.trim().isNotEmpty)
          'notes':
          notes.trim(),
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return RoadsideRequestModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Failed to create roadside request.'
        : 'Failed to create roadside request.';
  }
  Future<RoadsideRequestModel> createRequestX({
    required int roadsideServiceId,
    required int vehicleId,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.roadsideRequests,
      data: {
        'roadside_service_id': roadsideServiceId,
        'vehicle_id': vehicleId,
        'latitude': latitude,
        'longitude': longitude,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return RoadsideRequestModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Failed to create roadside request.'
        : 'Failed to create roadside request.';
  }


  Future<List<RoadsideVendorModel>> getNearbyVendors({
    required int roadsideServiceId,
    required double lat,
    required double lng,
  }) async {
    final response = await _apiClient.get(
      UrlApi.roadsideVendors,
      queryParameters: {
        'roadside_service_id': roadsideServiceId,
        'lat': lat,
        'lng': lng,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RoadsideVendorModel.fromJson)
          .toList();
    }

    return [];
  }
}