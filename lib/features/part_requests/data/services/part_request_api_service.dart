import 'package:dio/dio.dart';

import '../../../../core/constants/url_api.dart';
import '../../../../data/remote/api_client.dart';
import '../models/part_request_model.dart';

class PartRequestApiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PartRequestModel>> getRequests() async {
    final Response response = await _apiClient.get(
      UrlApi.partRequests,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map>()
          .map(
            (e) => PartRequestModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    throw _message(body, 'Failed to load part requests.');
  }

  Future<PartRequestModel> getRequest(
      int requestId,
      ) async {
    final Response response = await _apiClient.get(
      UrlApi.partRequestDetails(requestId),
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map) {
      return PartRequestModel.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    }

    throw _message(body, 'Failed to load part request.');
  }

  Future<PartRequestModel> createRequest({
    required int vehicleId,
    required int categoryId,
    required String quotationScope,
    required int quantity,
    int? addressId,
    String? brandPreference,
    String? notes,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.partRequests,
      data: {
        'vehicle_id': vehicleId,
        'category_id': categoryId,
        'quotation_scope': quotationScope,
        'quantity': quantity,
        if (addressId != null)
          'address_id': addressId,
        if (brandPreference != null &&
            brandPreference.trim().isNotEmpty)
          'brand_preference':
          brandPreference.trim(),
        if (notes != null &&
            notes.trim().isNotEmpty)
          'notes': notes.trim(),
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map) {
      return PartRequestModel.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    }

    throw _message(body, 'Failed to create part request.');
  }

  Future<void> cancelRequest(
      int requestId,
      ) async {
    final Response response = await _apiClient.post(
      UrlApi.cancelPartRequest(requestId),
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true) {
      return;
    }

    throw _message(body, 'Failed to cancel part request.');
  }

  Future<void> acceptQuotation({
    required int requestId,
    required int quotationId,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.acceptPartQuotation(
        requestId,
        quotationId,
      ),
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true) {
      return;
    }

    throw _message(body, 'Failed to accept quotation.');
  }

  Future<List<PartRequestVehicleOption>>
  getVehicles() async {
    final Response response = await _apiClient.get(
      UrlApi.vehicles,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map>()
          .map(
            (e) =>
            PartRequestVehicleOption.fromJson(
              Map<String, dynamic>.from(e),
            ),
      )
          .where((e) => e.id > 0)
          .toList();
    }

    throw _message(body, 'Failed to load vehicles.');
  }

  Future<List<PartRequestAddressOption>>
  getAddresses() async {
    final Response response = await _apiClient.get(
      UrlApi.addresses,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map>()
          .map(
            (e) =>
            PartRequestAddressOption.fromJson(
              Map<String, dynamic>.from(e),
            ),
      )
          .where((e) => e.id > 0)
          .toList();
    }

    throw _message(body, 'Failed to load addresses.');
  }

  String _message(
      dynamic body,
      String fallback,
      ) {
    if (body is Map) {
      final message = body['message']?.toString();

      if (message != null && message.isNotEmpty) {
        return message;
      }

      final errors = body['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;

        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }

        return first.toString();
      }
    }

    return fallback;
  }
}