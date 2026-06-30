import 'package:flutter/material.dart';
import 'package:talabatfresh/features/marketplace/data/models/marketplace_filter_model.dart';

import '../data/models/product_category_model.dart';
import '../data/models/product_model.dart';
import '../data/services/marketplace_api_service.dart';

class MarketplaceProvider extends ChangeNotifier {
  final MarketplaceApiService _apiService = MarketplaceApiService();

  bool isLoading = false;
  bool isLoadingDetails = false;
  String? errorMessage;

  List<ProductCategoryModel> categories = [];
  List<ProductModel> products = [];

  ProductModel? selectedProduct;

  int? selectedCategoryId;
  String? selectedProductType;
  String searchText = '';



  MarketplaceFilterOptionsModel? filterOptions;
  MarketplaceFilterState filter = MarketplaceFilterState();

  bool isLoadingFilters = false;

  Future<void> loadInitial() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final results = await Future.wait([
        _apiService.getCategories(),
        _apiService.getProducts(),
      ]);

      categories = results[0] as List<ProductCategoryModel>;
      products = results[1] as List<ProductModel>;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      products = await _apiService.getProducts(
        categoryId: selectedCategoryId,
        productType: selectedProductType,
        search: searchText,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectCategory(int? categoryId) async {
    selectedCategoryId = categoryId;
    await loadProducts();
  }

  Future<void> selectProductType(String? type) async {
    selectedProductType = type;

    filter = MarketplaceFilterState(
      productType: type,
    );

    await loadFilterOptions(productType: type);
    await loadFilteredProducts();
  }

  Future<void> selectProductTypeX(String? type) async {
    selectedProductType = type;
    await loadProducts();
  }


  Future<void> search(String value) async {
    searchText = value.trim();
    filter.search = searchText;
    await loadFilteredProducts();
  }
  Future<void> searchX(String value) async {
    searchText = value.trim();
    await loadProducts();
  }

  Future<void> loadProductDetails(int productId) async {
    try {
      isLoadingDetails = true;
      errorMessage = null;
      selectedProduct = null;
      notifyListeners();

      selectedProduct = await _apiService.getProductDetails(productId);

      isLoadingDetails = false;
      notifyListeners();
    } catch (e) {
      isLoadingDetails = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearFilters() {
    selectedCategoryId = null;
    selectedProductType = null;
    searchText = '';
    notifyListeners();
  }

  Future<void> loadByType(String type) async {
    selectedProductType = type;
    await loadProducts();
  }




  Future<void> loadFilterOptions({
    String? productType,
  }) async {
    try {
      isLoadingFilters = true;
      errorMessage = null;
      notifyListeners();

      filterOptions = await _apiService.getFilterOptions(
        productType: productType ?? selectedProductType,
      );

      isLoadingFilters = false;
      notifyListeners();
    } catch (e) {
      isLoadingFilters = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadFilteredProducts() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      filter.productType = selectedProductType;
      filter.search = searchText.isEmpty ? filter.search : searchText;

      products = await _apiService.getFilteredProducts(
        filter: filter,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> applyFilters(MarketplaceFilterState newFilter) async {
    filter = newFilter;
    filter.productType = selectedProductType;
    await loadFilteredProducts();
  }

  Future<void> clearAdvancedFilters() async {
    filter.clearKeepingType();
    await loadFilteredProducts();
  }
}