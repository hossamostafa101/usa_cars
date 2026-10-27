import 'package:flutter/material.dart';
import 'package:talabatfresh/models/user_model.dart';

import '../../../core/constants/cache_keys.dart';
import '../../../data/local/cache_helper.dart';
import '../../vehicles/data/models/vehicle_model.dart';

import '../data/services/profile_api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileApiService _profileApiService = ProfileApiService();

  bool isLoading = false;
  String? errorMessage;

  UserModel? user;

  List<VehicleModel> vehicles = [];

  bool isSubmitting = false;

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




  bool pushNotificationsEnabled = true;
  bool emailUpdatesEnabled = false;
  bool autoShareLocationEnabled = false;

  ProfileProvider() {
    _loadPreferences();
  }

  void _loadPreferences() {
    final pushValue = CacheHelper.getData(
      key: CacheKeys.pushNotificationsEnabled,
    );

    final emailValue = CacheHelper.getData(
      key: CacheKeys.emailUpdatesEnabled,
    );

    final locationValue = CacheHelper.getData(
      key: CacheKeys.autoShareLocationEnabled,
    );

    pushNotificationsEnabled =
    pushValue is bool ? pushValue : true;

    emailUpdatesEnabled =
    emailValue is bool ? emailValue : false;

    autoShareLocationEnabled =
    locationValue is bool ? locationValue : false;
  }

  Future<void> setPushNotificationsEnabled(
      bool value,
      ) async {
    pushNotificationsEnabled = value;
    notifyListeners();

    await CacheHelper.saveData(
      key: CacheKeys.pushNotificationsEnabled,
      value: value,
    );
  }

  Future<void> setEmailUpdatesEnabled(
      bool value,
      ) async {
    emailUpdatesEnabled = value;
    notifyListeners();

    await CacheHelper.saveData(
      key: CacheKeys.emailUpdatesEnabled,
      value: value,
    );
  }

  Future<void> setAutoShareLocationEnabled(
      bool value,
      ) async {
    autoShareLocationEnabled = value;
    notifyListeners();

    await CacheHelper.saveData(
      key: CacheKeys.autoShareLocationEnabled,
      value: value,
    );
  }




  Future<bool> updateProfile({
    required String name,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? preferredLanguage,
  }) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _profileApiService.updateProfile(
        name: name,
        phone: phone,
      );

      await _profileApiService.updateCustomerProfile(
        dateOfBirth: dateOfBirth,
        gender: gender,
        preferredLanguage:
        preferredLanguage,
      );

      await loadProfile();

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

  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _profileApiService.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation:
        passwordConfirmation,
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
}