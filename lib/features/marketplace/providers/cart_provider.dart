import 'package:flutter/material.dart';

import '../data/models/cart_model.dart';
import '../data/services/cart_api_service.dart';

class CartProvider extends ChangeNotifier {
  final CartApiService _cartApiService = CartApiService();

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  CartModel? cart;

  int get itemsCount => cart?.itemsCount ?? 0;
  double get subtotal => cart?.subtotal ?? 0;

  Future<void> loadCart() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      cart = await _cartApiService.getCart();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addItem({
    required int productId,
    required int qty,
    int? vehicleId,
  }) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      cart = await _cartApiService.addItem(
        productId: productId,
        qty: qty,
        vehicleId: vehicleId,
      );

      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItemQty({
    required int itemId,
    required int qty,
  }) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      cart = await _cartApiService.updateItemQty(
        itemId: itemId,
        qty: qty,
      );

      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(int itemId) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _cartApiService.removeItem(itemId);
      cart = await _cartApiService.getCart();

      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _cartApiService.clearCart();
      cart = await _cartApiService.getCart();

      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}