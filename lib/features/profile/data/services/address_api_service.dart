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
}