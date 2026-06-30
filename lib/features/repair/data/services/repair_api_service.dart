import 'package:dio/dio.dart';
import 'package:talabatfresh/data/remote/api_client.dart';

import '../../../../core/constants/url_api.dart';
import '../models/repair_model.dart';

class RepairApiService {
  final ApiClient _apiClient = ApiClient();

  Future<RepairHomeModel> getHome({
    double? lat,
    double? lng,
    int radius = 10,
  }) async {
    final Response response = await _apiClient.get(
      UrlApi.repairHome,
      queryParameters: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'radius': radius,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return RepairHomeModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Failed to load repair home.'
        : 'Failed to load repair home.';
  }

  Future<List<RepairWorkshopModel>> getWorkshops({
    int? serviceId,
    String? serviceType,
    double? lat,
    double? lng,
    int radius = 10,
    String? search,
  }) async {
    final Response response = await _apiClient.get(
      UrlApi.repairWorkshops,
      queryParameters: {
        if (serviceId != null) 'service_id': serviceId,
        if (serviceType != null) 'service_type': serviceType,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'radius': radius,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RepairWorkshopModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<RepairRequestModel> createRepairRequest({
    required int vehicleId,
    required int branchId,
    required int serviceId,
    required String issueTitle,
    String? issueDescription,
    String? preferredDate,
    String? preferredTime,
    bool pickupRequired = false,
    int? pickupAddressId,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.repairRequests,
      data: {
        'vehicle_id': vehicleId,
        'branch_id': branchId,
        'service_id': serviceId,
        'issue_title': issueTitle,
        if (issueDescription != null && issueDescription.trim().isNotEmpty)
          'issue_description': issueDescription.trim(),
        if (preferredDate != null) 'preferred_date': preferredDate,
        if (preferredTime != null) 'preferred_time': preferredTime,
        'pickup_required': pickupRequired,
        if (pickupAddressId != null) 'pickup_address_id': pickupAddressId,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return RepairRequestModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Failed to create repair request.'
        : 'Failed to create repair request.';
  }

  Future<List<RepairRequestModel>> getRequests() async {
    final Response response = await _apiClient.get(
      UrlApi.repairRequests,
    );

    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RepairRequestModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<void> cancelRequest(int requestId) async {
    await _apiClient.post(
      UrlApi.cancelRepairRequest(requestId),
    );
  }
}