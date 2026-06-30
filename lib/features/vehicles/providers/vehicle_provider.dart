import 'package:flutter/material.dart';

import '../data/models/vehicle_catalog_model.dart';
import '../data/models/vehicle_model.dart';
import '../data/services/vehicle_api_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleApiService _vehicleApiService = VehicleApiService();

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  List<VehicleModel> vehicles = [];
  List<VehicleMakeModel> makes = [];
  List<VehicleModelOption> models = [];

  Future<void> loadVehicles() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      vehicles = await _vehicleApiService.getVehicles();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMakes() async {
    makes = await _vehicleApiService.getMakes();
    notifyListeners();
  }

  Future<void> loadModelsByMake(int makeId) async {
    models = await _vehicleApiService.getModelsByMake(makeId);
    notifyListeners();
  }

  Future<bool> createVehicle(Map<String, dynamic> data) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _vehicleApiService.createVehicle(data);
      await loadVehicles();

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

  Future<bool> updateVehicle(int vehicleId, Map<String, dynamic> data) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _vehicleApiService.updateVehicle(vehicleId, data);
      await loadVehicles();

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

  Future<bool> setPrimary(int vehicleId) async {
    try {
      await _vehicleApiService.setPrimaryVehicle(vehicleId);
      await loadVehicles();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVehicle(int vehicleId) async {
    try {
      await _vehicleApiService.deleteVehicle(vehicleId);
      await loadVehicles();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}