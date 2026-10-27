import 'package:flutter/material.dart';

import '../data/models/roadside_model.dart';
import '../data/services/roadside_api_service.dart';

class RoadsideProvider extends ChangeNotifier {
  final RoadsideApiService _apiService = RoadsideApiService();

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  RoadsideHomeModel? home;

  List<RoadsideServiceModel> services = [];
  List<RoadsideRequestModel> recentRequests = [];

  RoadsideServiceModel? selectedService;

  RoadsideRequestModel? activeRequest;

  String get averageEta {
    return home?.averageEta.isNotEmpty == true
        ? home!.averageEta
        : '18-32 mins';
  }




  List<RoadsideVendorModel> nearbyVendors = [];
  RoadsideVendorModel? selectedVendor;
  bool isLoadingVendors = false;




  Future<void> loadHome() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      home = await _apiService.getHome();

      services = home?.services ?? [];
      recentRequests = home?.recentRequests ?? [];
      activeRequest = home?.activeRequest;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadServices() async {
    try {
      services = await _apiService.getServices();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
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

  void selectService(RoadsideServiceModel service) {
    selectedService = service;
    notifyListeners();
  }

  void clearSelectedService() {
    selectedService = null;
    notifyListeners();
  }



  Future<bool> createRequest({
    required int vehicleId,
    required double latitude,
    required double longitude,

    String? locationAddress,

    String? destinationAddress,
    double? destinationLatitude,
    double? destinationLongitude,

    String? notes,
    int? serviceId,
    int? branchId,
  }) async {
    try {
      final selectedServiceId =
          serviceId ??
              selectedService?.id;

      if (selectedServiceId ==
          null) {
        errorMessage =
        'Please select a roadside service.';

        notifyListeners();

        return false;
      }

      isSubmitting = true;
      errorMessage = null;

      notifyListeners();

      final request =
      await _apiService
          .createRequest(
        roadsideServiceId:
        selectedServiceId,

        vehicleId:
        vehicleId,

        branchId:
        branchId,

        latitude:
        latitude,

        longitude:
        longitude,

        locationAddress:
        locationAddress,

        destinationAddress:
        destinationAddress,

        destinationLatitude:
        destinationLatitude,

        destinationLongitude:
        destinationLongitude,

        notes:
        notes,
      );

      activeRequest =
          request;

      await loadHome();

      isSubmitting = false;

      notifyListeners();

      return true;
    } catch (e) {
      isSubmitting = false;

      errorMessage =
          e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> createRequestX({
    required int vehicleId,
    required double latitude,
    required double longitude,
    String? notes,
    int? serviceId,
  }) async {
    try {
      final selectedServiceId = serviceId ?? selectedService?.id;

      if (selectedServiceId == null) {
        errorMessage = 'Please select a roadside service.';
        notifyListeners();
        return false;
      }

      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      final request = await _apiService.createRequest(
        roadsideServiceId: selectedServiceId,
        vehicleId: vehicleId,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );

      activeRequest = request;

      await loadHome();

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



  Future<bool> loadNearbyVendors({
    required int roadsideServiceId,
    required double lat,
    required double lng,
  }) async {
    try {
      isLoadingVendors = true;
      errorMessage = null;
      nearbyVendors = [];
      selectedVendor = null;
      notifyListeners();

      nearbyVendors = await _apiService.getNearbyVendors(
        roadsideServiceId: roadsideServiceId,
        lat: lat,
        lng: lng,
      );

      isLoadingVendors = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoadingVendors = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void selectVendor(RoadsideVendorModel? vendor) {
    selectedVendor = vendor;
    notifyListeners();
  }
}