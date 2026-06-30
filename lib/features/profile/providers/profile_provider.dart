import 'package:flutter/material.dart';
import 'package:talabatfresh/models/user_model.dart';

import '../../vehicles/data/models/vehicle_model.dart';

import '../data/services/profile_api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileApiService _profileApiService = ProfileApiService();

  bool isLoading = false;
  String? errorMessage;

  UserModel? user;

  List<VehicleModel> vehicles = [];

  Future<void> loadProfile() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      final results = await Future.wait([
        _profileApiService.getProfile(),
        _profileApiService.getVehicles(),
      ]);

      user = results[0] as UserModel?;
      vehicles = results[1] as List<VehicleModel>;

      isLoading = false;

      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();

      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  VehicleModel? get primaryVehicle {
    try {
      return vehicles.firstWhere(
            (e) => e.isPrimary,
      );
    } catch (_) {
      if (vehicles.isNotEmpty) {
        return vehicles.first;
      }

      return null;
    }
  }
}