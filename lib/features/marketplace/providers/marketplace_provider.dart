import 'package:flutter/material.dart';
import 'package:talabatfresh/features/marketplace/data/models/marketplace_filter_model.dart';

import '../data/models/product_category_model.dart';
import '../data/models/product_model.dart';
import '../data/services/marketplace_api_service.dart';

class MarketplaceProvider extends ChangeNotifier {
  final MarketplaceApiService _apiService = MarketplaceApiService();

  bool isLoading = false;
  bool isLoadingDetails = false;
  bool isLoadingFilters = false;

  String? errorMessage;

  List<ProductCategoryModel> categories = [];
  List<ProductModel> products = [];

  ProductModel? selectedProduct;

  int? selectedCategoryId;
  String? selectedProductType;
  String searchText = '';

  MarketplaceFilterOptionsModel? filterOptions;
  MarketplaceFilterState filter = MarketplaceFilterState();

  // =========================================================
  // Hierarchical category navigation
  // =========================================================

  final List<ProductCategoryModel> categoryPath = [];

  ProductCategoryModel? selectedLeafCategory;

  bool get isAtCategoryRoot =>
      categoryPath.isEmpty && selectedLeafCategory == null;

  bool get isViewingLeafProducts => selectedLeafCategory != null;

  bool get canGoBackCategory =>
      selectedLeafCategory != null || categoryPath.isNotEmpty;

  String get currentCategoryTitle {
    if (selectedLeafCategory != null) {
      return selectedLeafCategory!.name;
    }

    if (categoryPath.isNotEmpty) {
      return categoryPath.last.name;
    }

    return selectedProductType == 'tire' ? 'Tires' : 'All Parts';
  }

  // =========================================================
  // Initial loading
  // =========================================================

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

  // =========================================================
  // Root categories
  // =========================================================

  Future<void> loadRootCategories() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      List<ProductCategoryModel> result;

      if (selectedProductType == 'tire') {
        result = await _apiService.getCategories(
          categoryType: 'tires',
        );
      } else {
        result = await _apiService.getCategories();

        // Parts tab contains parts + accessories.
        // Tires remain in their own tab.
        result = result.where((category) {
          return category.categoryType == 'parts' ||
              category.categoryType == 'accessories';
        }).toList();
      }

      categories = result;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // =========================================================
  // Category navigation
  // =========================================================

  Future<void> openCategory(ProductCategoryModel category) async {
    if (category.id == null) {
      return;
    }

    // Tires currently keep their existing behavior.
    if (selectedProductType == 'tire') {
      selectedCategoryId = category.id;

      filter.categoryId = category.id;

      await loadFilteredProducts();
      return;
    }

    // Parent category:
    // load only its direct children.
    if (category.hasChildren) {
      try {
        isLoading = true;
        errorMessage = null;
        notifyListeners();

        final children = await _apiService.getCategories(
          parentId: category.id,
        );

        categoryPath.add(category);

        selectedLeafCategory = null;
        selectedCategoryId = null;

        filter.categoryId = null;

        categories = children;

        // Do not show unrelated products while browsing the tree.
        products = [];

        isLoading = false;
        notifyListeners();
      } catch (e) {
        isLoading = false;
        errorMessage = e.toString();
        notifyListeners();
      }

      return;
    }

    // Leaf category:
    // now we can request vendor products for this exact part type.
    selectedLeafCategory = category;
    selectedCategoryId = category.id;

    filter.categoryId = category.id;

    await loadFilteredProducts();
  }

  Future<void> goBackCategory() async {
    // From product results back to the leaf list.
    if (selectedLeafCategory != null) {
      selectedLeafCategory = null;
      selectedCategoryId = null;

      filter.categoryId = null;

      products = [];

      notifyListeners();
      return;
    }

    if (categoryPath.isEmpty) {
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      categoryPath.removeLast();

      selectedCategoryId = null;
      selectedLeafCategory = null;

      filter.categoryId = null;

      if (categoryPath.isEmpty) {
        List<ProductCategoryModel> result;

        if (selectedProductType == 'tire') {
          result = await _apiService.getCategories(
            categoryType: 'tires',
          );
        } else {
          result = await _apiService.getCategories();

          result = result.where((category) {
            return category.categoryType == 'parts' ||
                category.categoryType == 'accessories';
          }).toList();
        }

        categories = result;

        // At root we can show general marketplace products again.
        products = await _apiService.getFilteredProducts(
          filter: MarketplaceFilterState(
            productType: selectedProductType,
          ),
        );
      } else {
        final parent = categoryPath.last;

        categories = await _apiService.getCategories(
          parentId: parent.id,
        );

        products = [];
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Kept because the current PartsPage already calls this method.
  Future<void> selectCategory(int? categoryId) async {
    if (categoryId == null) {
      selectedCategoryId = null;
      selectedLeafCategory = null;

      filter.categoryId = null;

      await loadFilteredProducts();
      return;
    }

    ProductCategoryModel? foundCategory;

    for (final category in categories) {
      if (category.id == categoryId) {
        foundCategory = category;
        break;
      }
    }

    if (foundCategory != null) {
      await openCategory(foundCategory);
      return;
    }

    // Fallback for an ID not present in the currently displayed level.
    selectedCategoryId = categoryId;
    filter.categoryId = categoryId;

    await loadFilteredProducts();
  }

  // =========================================================
  // Product type
  // =========================================================

  Future<void> selectProductType(String? type) async {
    selectedProductType = type;

    selectedCategoryId = null;
    selectedLeafCategory = null;

    categoryPath.clear();

    searchText = '';

    filter = MarketplaceFilterState(
      productType: type,
    );

    filterOptions = null;

    await loadRootCategories();

    await loadFilterOptions(
      productType: type,
    );

    await loadFilteredProducts();
  }

  Future<void> selectProductTypeX(String? type) async {
    selectedProductType = type;
    await loadProducts();
  }

  Future<void> loadByType(String type) async {
    selectedProductType = type;
    await loadProducts();
  }

  // =========================================================
  // Products
  // =========================================================

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

  Future<void> loadFilteredProducts() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      filter.productType = selectedProductType;

      filter.search = searchText.trim().isEmpty
          ? null
          : searchText.trim();

      // For Parts, category filtering must come from the selected leaf.
      if (selectedProductType == 'part') {
        filter.categoryId = selectedLeafCategory?.id;
      }

      // Tires can continue using their selected category if one exists.
      if (selectedProductType == 'tire') {
        filter.categoryId = selectedCategoryId;
      }

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

  // =========================================================
  // Search
  // =========================================================

  Future<void> search(String value) async {
    searchText = value.trim();

    filter.search = searchText.isEmpty
        ? null
        : searchText;

    await loadFilteredProducts();
  }

  Future<void> searchX(String value) async {
    searchText = value.trim();
    await loadProducts();
  }

  // =========================================================
  // Product details
  // =========================================================

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

  // =========================================================
  // Filter options
  // =========================================================

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

  Future<void> applyFilters(
      MarketplaceFilterState newFilter,
      ) async {
    filter = newFilter;

    filter.productType = selectedProductType;

    // Category selection is controlled by the category browser,
    // not by the advanced filter sheet.
    if (selectedProductType == 'part') {
      filter.categoryId = selectedLeafCategory?.id;
    }

    if (selectedProductType == 'tire') {
      filter.categoryId = selectedCategoryId;
    }

    await loadFilteredProducts();
  }

  Future<void> clearAdvancedFilters() async {
    filter.clearKeepingType();

    if (selectedProductType == 'part') {
      filter.categoryId = selectedLeafCategory?.id;
    }

    if (selectedProductType == 'tire') {
      filter.categoryId = selectedCategoryId;
    }

    await loadFilteredProducts();
  }

  // =========================================================
  // Reset
  // =========================================================

  void clearFilters() {
    selectedCategoryId = null;
    selectedLeafCategory = null;
    selectedProductType = null;

    categoryPath.clear();

    searchText = '';

    filter = MarketplaceFilterState();

    filterOptions = null;

    categories = [];
    products = [];

    errorMessage = null;

    notifyListeners();
  }
}