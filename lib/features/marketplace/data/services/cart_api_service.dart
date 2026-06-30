import 'package:dio/dio.dart';

import '../../../../core/constants/url_api.dart';
import '../../../../data/remote/api_client.dart';
import '../models/cart_model.dart';

class CartApiService {
  final ApiClient _apiClient = ApiClient();

  Future<CartModel?> getCart() async {
    final Response response = await _apiClient.get(
      UrlApi.cart,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return CartModel.fromJson(body['data']);
    }

    return null;
  }

  Future<CartModel?> addItem({
    required int productId,
    required int qty,
    int? vehicleId,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.cartItems,
      data: {
        'product_id': productId,
        'qty': qty,
        if (vehicleId != null) 'vehicle_id': vehicleId,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return CartModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Failed to add item to cart.'
        : 'Failed to add item to cart.';
  }

  Future<CartModel?> updateItemQty({
    required int itemId,
    required int qty,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.cartItemDetails(itemId),
      data: {
        'qty': qty,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return CartModel.fromJson(body['data']);
    }

    return await getCart();
  }

  Future<void> removeItem(int itemId) async {
    await _apiClient.delete(
      UrlApi.cartItemDetails(itemId),
    );
  }

  Future<void> clearCart() async {
    await _apiClient.delete(
      UrlApi.cart,
    );
  }
}