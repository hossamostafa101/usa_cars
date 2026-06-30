import 'package:flutter/material.dart';

import '../data/models/customer_home_model.dart';
import '../data/services/customer_home_api_service.dart';

class CustomerHomeProvider extends ChangeNotifier {
  final CustomerHomeApiService _homeApiService = CustomerHomeApiService();

  bool isLoading = false;
  String? errorMessage;

  CustomerHomeModel? home;

  bool get hasData => home != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  Future<void> loadHome() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      home = await _homeApiService.getHome();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshHome() async {
    await loadHome();
  }

  void clear() {
    home = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}