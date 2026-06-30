// import 'package:flutter/material.dart';
//
// class HomeProvider extends ChangeNotifier {
//   final VehicleApiService _vehicleApiService = VehicleApiService();
//
//   bool isLoading = false;
//   String? errorMessage;
//
//   VehicleModel? primaryVehicle;
//   List<VehicleModel> vehicles = [];
//
//   Future<void> loadHome() async {
//     try {
//       isLoading = true;
//       errorMessage = null;
//       notifyListeners();
//
//       vehicles = await _vehicleApiService.getVehicles();
//
//       primaryVehicle = vehicles.firstWhere(
//             (vehicle) => vehicle.isPrimary,
//         orElse: () => vehicles.isNotEmpty ? vehicles.first : const VehicleModel(),
//       );
//
//       isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       isLoading = false;
//       errorMessage = e.toString();
//       notifyListeners();
//     }
//   }
// }