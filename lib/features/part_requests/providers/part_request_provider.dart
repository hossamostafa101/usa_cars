import 'package:flutter/material.dart';

import '../../marketplace/data/models/product_category_model.dart';
import '../../marketplace/data/services/marketplace_api_service.dart';
import '../data/models/part_request_model.dart';
import '../data/services/part_request_api_service.dart';

class PartRequestProvider extends ChangeNotifier {
  final PartRequestApiService _api =
  PartRequestApiService();

  final MarketplaceApiService _catalogApi =
  MarketplaceApiService();

  bool isLoading = false;
  bool isSubmitting = false;
  bool isCategoryLoading = false;

  String? errorMessage;

  List<PartRequestModel> requests = [];

  PartRequestModel? selectedRequest;

  List<PartRequestVehicleOption> vehicles = [];

  List<PartRequestAddressOption> addresses = [];

  final List<List<ProductCategoryModel>>
  _categoryLevels = [];

  final List<ProductCategoryModel>
  categoryPath = [];

  ProductCategoryModel? selectedCategory;


  String _categoryType = 'parts';

  String get categoryType => _categoryType;

  bool get isTireRequest => _categoryType == 'tires';


  List<ProductCategoryModel> get currentCategories {
    if (_categoryLevels.isEmpty) {
      return [];
    }

    return _categoryLevels.last;
  }

  int? get preferredVehicleId {
    if (vehicles.isEmpty) return null;

    final index = vehicles.indexWhere(
          (e) => e.isPrimary,
    );

    if (index >= 0) {
      return vehicles[index].id;
    }

    return vehicles.first.id;
  }

  int? get preferredAddressId {
    final valid = addresses
        .where((e) => e.hasCoordinates)
        .toList();

    if (valid.isEmpty) return null;

    final index = valid.indexWhere(
          (e) => e.isDefault,
    );

    if (index >= 0) {
      return valid[index].id;
    }

    return valid.first.id;
  }

  List<PartRequestAddressOption>
  get nearbyAddresses {
    return addresses
        .where((e) => e.hasCoordinates)
        .toList();
  }

  Future<void> loadRequests() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      requests = await _api.getRequests();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRequest(
      int requestId,
      ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      selectedRequest =
      await _api.getRequest(requestId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> loadCreateData() async {
  Future<void> loadCreateData({
    String categoryType = 'parts',
  }) async {
    try {

      _categoryType = categoryType;

      isLoading = true;
      errorMessage = null;

      vehicles = [];
      addresses = [];

      _categoryLevels.clear();
      categoryPath.clear();
      selectedCategory = null;

      notifyListeners();

      final result = await Future.wait([
        _api.getVehicles(),
        _api.getAddresses(),
        _catalogApi.getCategories(
          categoryType: _categoryType,
        ),
      ]);

      vehicles =
      result[0] as List<PartRequestVehicleOption>;

      addresses =
      result[1] as List<PartRequestAddressOption>;

      final roots =
      result[2] as List<ProductCategoryModel>;

      _categoryLevels.add(roots);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openCategory(
      ProductCategoryModel category,
      ) async {
    final categoryId = category.id;

    if (categoryId == null) return;

    try {
      isCategoryLoading = true;
      errorMessage = null;
      notifyListeners();

      final children =
      await _catalogApi.getCategories(
        categoryType: _categoryType,
        parentId: categoryId,
      );

      if (children.isEmpty) {
        selectedCategory = category;
      } else {
        selectedCategory = null;
        categoryPath.add(category);
        _categoryLevels.add(children);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isCategoryLoading = false;
      notifyListeners();
    }
  }

  void categoryBack() {
    if (_categoryLevels.length <= 1) {
      selectedCategory = null;
      notifyListeners();
      return;
    }

    _categoryLevels.removeLast();

    if (categoryPath.isNotEmpty) {
      categoryPath.removeLast();
    }

    selectedCategory = null;

    notifyListeners();
  }

  void changeSelectedCategory() {
    selectedCategory = null;
    notifyListeners();
  }

  Future<PartRequestModel?> createRequest({
    required int vehicleId,
    required String quotationScope,
    required int quantity,
    int? addressId,
    String? brandPreference,
    String? notes,
  }) async {
    final categoryId = selectedCategory?.id;

    if (categoryId == null) {
      errorMessage = isTireRequest
          ? 'Please select an exact tire type.'
          : 'Please select an exact part type.';
      notifyListeners();
      return null;
    }

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      final request = await _api.createRequest(
        vehicleId: vehicleId,
        categoryId: categoryId,
        quotationScope: quotationScope,
        quantity: quantity,
        addressId: addressId,
        brandPreference: brandPreference,
        notes: notes,
      );

      requests.insert(0, request);

      return request;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> acceptQuotation({
    required int requestId,
    required int quotationId,
  }) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _api.acceptQuotation(
        requestId: requestId,
        quotationId: quotationId,
      );

      await loadRequest(requestId);
      await loadRequests();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> cancelRequest(
      int requestId,
      ) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _api.cancelRequest(requestId);

      await loadRequest(requestId);
      await loadRequests();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> refreshVehicles() async {
    try {
      errorMessage = null;

      vehicles = await _api.getVehicles();

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}