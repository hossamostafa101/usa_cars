import 'package:dio/dio.dart';
import 'package:talabatfresh/data/remote/api_client.dart';

import '../../../../core/constants/url_api.dart';
import '../models/order_model.dart';

class OrderApiService {
  final ApiClient _apiClient = ApiClient();

  Future<OrderModel> checkout({
    required int billingAddressId,
    required int shippingAddressId,
    required double shippingAmount,
    required double taxAmount,
    String? notes,
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.checkout,
      data: {
        'billing_address_id': billingAddressId,
        'shipping_address_id': shippingAddressId,
        'shipping_amount': shippingAmount,
        'tax_amount': taxAmount,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return OrderModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Checkout failed.'
        : 'Checkout failed.';
  }

  Future<PaymentModel> payOrder({
    required int orderId,
    String method = 'cash',
  }) async {
    final Response response = await _apiClient.post(
      UrlApi.pay,
      data: {
        'payment_type': 'order',
        'order_id': orderId,
        'method': method,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return PaymentModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Payment failed.'
        : 'Payment failed.';
  }

  Future<PaymentModel> markPaid(int paymentId) async {
    final Response response = await _apiClient.post(
      UrlApi.markPaymentPaid(paymentId),
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return PaymentModel.fromJson(body['data']);
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Mark paid failed.'
        : 'Mark paid failed.';
  }









  Future<List<OrderModel>> getOrders({
    String? orderStatus,
    String? paymentStatus,
    int perPage = 50,
  }) async {
    final Response response = await _apiClient.get(
      UrlApi.orders,
      queryParameters: {
        if (orderStatus != null &&
            orderStatus.trim().isNotEmpty)
          'order_status': orderStatus.trim(),
        if (paymentStatus != null &&
            paymentStatus.trim().isNotEmpty)
          'payment_status': paymentStatus.trim(),
        'per_page': perPage,
      },
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true) {
      final data = body['data'];

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(OrderModel.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic> &&
          data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(OrderModel.fromJson)
            .toList();
      }
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to load orders.'
        : 'Failed to load orders.';
  }

  Future<OrderModel> getOrderDetails(
      int orderId,
      ) async {
    final Response response = await _apiClient.get(
      UrlApi.orderDetails(orderId),
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return OrderModel.fromJson(
        body['data'],
      );
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to load order.'
        : 'Failed to load order.';
  }

  Future<OrderModel> cancelOrder(
      int orderId,
      ) async {
    final Response response = await _apiClient.post(
      UrlApi.cancelOrder(orderId),
      data: {},
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true &&
        body['data'] is Map<String, dynamic>) {
      return OrderModel.fromJson(
        body['data'],
      );
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to cancel order.'
        : 'Failed to cancel order.';
  }
}