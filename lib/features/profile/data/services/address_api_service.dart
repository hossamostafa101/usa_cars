import 'package:dio/dio.dart';
import 'package:talabatfresh/data/remote/api_client.dart';

import '../../../../core/constants/url_api.dart';
import '../models/address_model.dart';

class AddressApiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AddressModel>> getAddresses() async {
    final Response response = await _apiClient.get(UrlApi.addresses);

    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(AddressModel.fromJson)
          .toList();
    }

    return [];
  }



  Future<AddressModel> createAddress({
    required Map<String, dynamic> data,
  }) async {
    final Response response =
    await _apiClient.post(
      UrlApi.addresses,
      data: data,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return AddressModel.fromJson(
        body['data'],
      );
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to create address.'
        : 'Failed to create address.';
  }

  Future<AddressModel> updateAddress({
    required int addressId,
    required Map<String, dynamic> data,
  }) async {
    final Response response =
    await _apiClient.post(
      UrlApi.addressDetails(
        addressId,
      ),
      data: data,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return AddressModel.fromJson(
        body['data'],
      );
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to update address.'
        : 'Failed to update address.';
  }

  Future<void> setDefault(
      int addressId,
      ) async {
    final Response response =
    await _apiClient.post(
      UrlApi.setDefaultAddress(
        addressId,
      ),
      data: {},
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true) {
      return;
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to set default address.'
        : 'Failed to set default address.';
  }

  Future<void> deleteAddress(
      int addressId,
      ) async {
    final Response response =
    await _apiClient.delete(
      UrlApi.addressDetails(
        addressId,
      ),
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true) {
      return;
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to delete address.'
        : 'Failed to delete address.';
  }

}