import 'package:dio/dio.dart';
import 'package:talabatfresh/data/remote/api_client.dart';

import '../../../../core/constants/url_api.dart';
import '../models/customer_home_model.dart';

class CustomerHomeApiService {
  final ApiClient _apiClient = ApiClient();

  Future<CustomerHomeModel> getHome() async {
    final Response response = await _apiClient.get(
      UrlApi.customerHome,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return CustomerHomeModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Failed to load home.'
        : 'Failed to load home.';
  }
}