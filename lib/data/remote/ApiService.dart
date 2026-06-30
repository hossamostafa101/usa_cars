import 'package:talabatfresh/data/remote/url_api.dart';
import 'package:dio/dio.dart';
import 'package:talabatfresh/pages/home_page.dart';
import '../local/cache_helper.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options
      ..baseUrl = BASE_URL
      ..connectTimeout = const Duration(seconds: 20)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers = {
        'Accept': 'application/json',
      };
  }

  String? get _token => CacheHelper.getData(key: 'token');

  Options _authOptions() {
    final token = _token;
    return Options(
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }


}