import 'package:flutter/material.dart';

import '../data/models/repair_model.dart';
import '../data/services/repair_api_service.dart';

class RepairProvider extends ChangeNotifier {
  final RepairApiService _apiService = RepairApiService();

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  RepairHomeModel? home;

  List<RepairServiceCategoryModel> serviceCategories = [];
  List<RepairServiceModel> popularServices = [];
  List<RepairWorkshopModel> repairWorkshops = [];
  List<RepairWorkshopModel> bodyRepairWorkshops = [];
  List<RepairRequestModel> recentRequests = [];

  RepairServiceCategoryModel? selectedCategory;
  RepairServiceModel? selectedService;

  String searchText = '';

  Future<void> loadHome({
    double? lat,
    double? lng,
    int radius = 10,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      home = await _apiService.getHome(
        lat: lat,
        lng: lng,
        radius: radius,
      );

      serviceCategories = home?.serviceCategories ?? [];
      popularServices = home?.popularServices ?? [];
      repairWorkshops = home?.repairWorkshops ?? [];
      bodyRepairWorkshops = home?.bodyRepairWorkshops ?? [];
      recentRequests = home?.recentRequests ?? [];

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadWorkshops({
    int? serviceId,
    String? serviceType,
    double? lat,
    double? lng,
    int radius = 10,
    String? search,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final workshops = await _apiService.getWorkshops(
        serviceId: serviceId ?? selectedService?.id,
        serviceType: serviceType,
        lat: lat,
        lng: lng,
        radius: radius,
        search: search ?? searchText,
      );

      if (serviceType == 'body') {
        bodyRepairWorkshops = workshops;
      } else {
        repairWorkshops = workshops;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectCategory(RepairServiceCategoryModel category) async {
    selectedCategory = category;
    notifyListeners();
  }

  Future<void> selectService(RepairServiceModel service) async {
    selectedService = service;
    notifyListeners();
  }

  Future<void> searchWorkshops(String value) async {
    searchText = value.trim();
    await loadWorkshops(search: searchText);
  }

  Future<bool> createRepairRequest({
    required int vehicleId,
    required int branchId,
    required int serviceId,
    required String issueTitle,
    String? issueDescription,
    String? preferredDate,
    String? preferredTime,
    bool pickupRequired = false,
    int? pickupAddressId,
  }) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _apiService.createRepairRequest(
        vehicleId: vehicleId,
        branchId: branchId,
        serviceId: serviceId,
        issueTitle: issueTitle,
        issueDescription: issueDescription,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
        pickupRequired: pickupRequired,
        pickupAddressId: pickupAddressId,
      );

      recentRequests = await _apiService.getRequests();

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

  Future<void> loadRequests() async {
    try {
      recentRequests = await _apiService.getRequests();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> cancelRequest(int requestId) async {
    try {
      errorMessage = null;
      notifyListeners();

      await _apiService.cancelRequest(requestId);
      await loadRequests();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}