import 'package:flutter/material.dart';
import 'package:talabatfresh/features/marketplace/data/models/order_model.dart';
import 'package:talabatfresh/features/marketplace/data/services/order_api_service.dart';

import '../../profile/data/models/address_model.dart';
import '../../profile/data/services/address_api_service.dart';

class PlaceOrderProvider extends ChangeNotifier {
  final OrderApiService _orderApiService = OrderApiService();
  final AddressApiService _addressApiService = AddressApiService();

  bool isLoading = false;
  bool isPlacingOrder = false;

  String? errorMessage;

  List<AddressModel> addresses = [];
  AddressModel? selectedShippingAddress;
  AddressModel? selectedBillingAddress;

  OrderModel? order;
  PaymentModel? payment;

  Future<void> loadCheckoutData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      addresses = await _addressApiService.getAddresses();

      if (addresses.isNotEmpty) {
        selectedShippingAddress = addresses.firstWhere(
              (e) => e.isDefault,
          orElse: () => addresses.first,
        );

        selectedBillingAddress = selectedShippingAddress;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void selectShippingAddress(AddressModel address) {
    selectedShippingAddress = address;
    selectedBillingAddress ??= address;
    notifyListeners();
  }

  void selectBillingAddress(AddressModel address) {
    selectedBillingAddress = address;
    notifyListeners();
  }

  Future<bool> placeOrderAndSimulatePayment({
    required double shippingAmount,
    required double taxAmount,
    String? notes,
  }) async {
    try {
      if (selectedShippingAddress?.id == null) {
        errorMessage = 'Please select shipping address.';
        notifyListeners();
        return false;
      }

      if (selectedBillingAddress?.id == null) {
        errorMessage = 'Please select billing address.';
        notifyListeners();
        return false;
      }

      isPlacingOrder = true;
      errorMessage = null;
      notifyListeners();

      order = await _orderApiService.checkout(
        billingAddressId: selectedBillingAddress!.id!,
        shippingAddressId: selectedShippingAddress!.id!,
        shippingAmount: shippingAmount,
        taxAmount: taxAmount,
        notes: notes,
      );

      if (order?.id == null) {
        throw 'Order was created but ID is missing.';
      }

      payment = await _orderApiService.payOrder(
        orderId: order!.id!,
        method: 'cash',
      );

      if (payment?.id != null) {
        payment = await _orderApiService.markPaid(payment!.id!);
      }

      isPlacingOrder = false;
      notifyListeners();

      return true;
    } catch (e) {
      isPlacingOrder = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clear() {
    order = null;
    payment = null;
    errorMessage = null;
    isLoading = false;
    isPlacingOrder = false;
    notifyListeners();
  }
}