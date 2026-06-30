import 'package:dio/dio.dart';
import 'package:talabatfresh/features/marketplace/data/models/marketplace_filter_model.dart';

import '../../../../core/constants/url_api.dart';
import '../../../../data/remote/api_client.dart';
import '../models/product_category_model.dart';
import '../models/product_model.dart';

class MarketplaceApiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProductCategoryModel>> getCategories({
    String? categoryType,
    int? parentId,
  }) async {
    final Response response = await _apiClient.get(
      UrlApi.marketplaceCategories,
      queryParameters: {
        if (categoryType != null) 'category_type': categoryType,
        if (parentId != null) 'parent_id': parentId,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ProductCategoryModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<List<ProductModel>> getProducts({
    int? categoryId,
    String? productType,
    int? vendorId,
    String? brand,
    String? search,
    double? minPrice,
    double? maxPrice,
    int perPage = 15,
  }) async {
    final Response response = await _apiClient.get(
      UrlApi.marketplaceProducts,
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (productType != null) 'product_type': productType,
        if (vendorId != null) 'vendor_id': vendorId,
        if (brand != null && brand.isNotEmpty) 'brand': brand,
        if (search != null && search.isNotEmpty) 'search': search,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        'per_page': perPage,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['data'] is Map<String, dynamic> &&
        body['data']['data'] is List) {
      return (body['data']['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<ProductModel?> getProductDetails(int productId) async {
    final Response response = await _apiClient.get(
      UrlApi.marketplaceProductDetails(productId),
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return ProductModel.fromJson(body['data']);
    }

    return null;
  }



  Future<MarketplaceFilterOptionsModel> getFilterOptions({
    String? productType,
  }) async {
    final Response response = await _apiClient.get(
      UrlApi.marketplaceFilterOptions,
      queryParameters: {
        if (productType != null) 'product_type': productType,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return MarketplaceFilterOptionsModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Failed to load filter options.'
        : 'Failed to load filter options.';
  }

  Future<List<ProductModel>> getFilteredProducts({
    required MarketplaceFilterState filter,
    int perPage = 15,
  }) async {
    final Response response = await _apiClient.get(
      UrlApi.marketplaceProductsFilter,
      queryParameters: {
        ...filter.toQuery(),
        'per_page': perPage,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['data'] is Map<String, dynamic> &&
        body['data']['data'] is List) {
      return (body['data']['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<List<ProductModel>> getBrandProducts({
    required String brand,
    String? productType,
    String? sort,
    int perPage = 15,
  }) async {
    final Response response = await _apiClient.get(
      UrlApi.marketplaceBrandProducts(brand),
      queryParameters: {
        if (productType != null) 'product_type': productType,
        if (sort != null) 'sort': sort,
        'per_page': perPage,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['data'] is Map<String, dynamic> &&
        body['data']['data'] is List) {
      return (body['data']['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    }

    return [];
  }
}