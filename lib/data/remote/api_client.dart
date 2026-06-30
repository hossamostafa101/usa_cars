import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talabatfresh/core/constants/cache_keys.dart';
import 'package:talabatfresh/core/constants/url_api.dart';
import 'package:talabatfresh/data/local/cache_helper.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: UrlApi.baseUrl,
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),

        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _initializeInterceptors();
  }

  late Dio _dio;

  Dio get client => _dio;

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = CacheHelper.getData(key:CacheKeys.token);

          if (token != null && token.toString().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },

        onError: (error, handler) async {
          return handler.next(error);
        },
      ),
    );
  }

  // ============================
  // GET
  // ============================

  Future<Response> get(
      String url, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================
  // POST
  // ============================

  Future<Response> post(
      String url, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================
  // PUT
  // ============================

  Future<Response> put(
      String url, {
        dynamic data,
      }) async {
    try {
      return await _dio.put(
        url,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================
  // DELETE
  // ============================

  Future<Response> delete(
      String url, {
        dynamic data,
      }) async {
    try {
      return await _dio.delete(
        url,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================
  // MULTIPART
  // ============================

  Future<Response> postMultipart(
      String url, {
        required Map<String, dynamic> data,
      }) async {
    try {
      final formData = FormData.fromMap(data);

      return await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================
  // ERROR HANDLER
  // ============================

  String _handleError(DioException error) {
    // backend validation message
    if (error.response != null) {
      final response = error.response?.data;

      if (response is Map<String, dynamic>) {
        // message
        if (response['message'] != null) {
          return response['message'].toString();
        }

        // errors object
        if (response['errors'] != null) {
          return _extractValidationErrors(response['errors']);
        }
      }
    }

    // timeout
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout.';
    }

    // no internet
    if (error.error is SocketException) {
      return 'No internet connection.';
    }

    return 'Something went wrong.';
  }

  String _extractValidationErrors(dynamic errors) {
    if (errors is Map<String, dynamic>) {
      final messages = <String>[];

      errors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          messages.add(value.first.toString());
        }
      });

      return messages.join('\n');
    }

    return 'Validation error.';
  }
}