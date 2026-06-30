import 'product_category_model.dart';

class MarketplaceFilterOptionsModel {
  final List<ProductCategoryModel> categories;
  final List<String> brands;
  final PriceRangeModel? priceRange;
  final List<VehicleMakeFilterModel> vehicleMakes;
  final List<VehicleModelFilterModel> vehicleModels;
  final TireFiltersModel? tireFilters;
  final List<SortOptionModel> sortOptions;

  const MarketplaceFilterOptionsModel({
    this.categories = const [],
    this.brands = const [],
    this.priceRange,
    this.vehicleMakes = const [],
    this.vehicleModels = const [],
    this.tireFilters,
    this.sortOptions = const [],
  });

  factory MarketplaceFilterOptionsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MarketplaceFilterOptionsModel();

    return MarketplaceFilterOptionsModel(
      categories: json['categories'] is List
          ? (json['categories'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ProductCategoryModel.fromJson)
          .toList()
          : [],
      brands: json['brands'] is List
          ? (json['brands'] as List).map((e) => e.toString()).toList()
          : [],
      priceRange: json['price_range'] is Map<String, dynamic>
          ? PriceRangeModel.fromJson(json['price_range'])
          : null,
      vehicleMakes: json['vehicle_makes'] is List
          ? (json['vehicle_makes'] as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleMakeFilterModel.fromJson)
          .toList()
          : [],
      vehicleModels: json['vehicle_models'] is List
          ? (json['vehicle_models'] as List)
          .whereType<Map<String, dynamic>>()
          .map(VehicleModelFilterModel.fromJson)
          .toList()
          : [],
      tireFilters: json['tire_filters'] is Map<String, dynamic>
          ? TireFiltersModel.fromJson(json['tire_filters'])
          : null,
      sortOptions: json['sort_options'] is List
          ? (json['sort_options'] as List)
          .whereType<Map<String, dynamic>>()
          .map(SortOptionModel.fromJson)
          .toList()
          : [],
    );
  }
}

class PriceRangeModel {
  final double? min;
  final double? max;

  const PriceRangeModel({
    this.min,
    this.max,
  });

  factory PriceRangeModel.fromJson(Map<String, dynamic> json) {
    return PriceRangeModel(
      min: _toDouble(json['min']),
      max: _toDouble(json['max']),
    );
  }
}

class TireFiltersModel {
  final List<String> sizes;
  final List<int> widths;
  final List<int> aspectRatios;
  final List<int> rimDiameters;
  final List<String> seasons;

  const TireFiltersModel({
    this.sizes = const [],
    this.widths = const [],
    this.aspectRatios = const [],
    this.rimDiameters = const [],
    this.seasons = const [],
  });

  factory TireFiltersModel.fromJson(Map<String, dynamic> json) {
    return TireFiltersModel(
      sizes: _stringList(json['sizes']),
      widths: _intList(json['widths']),
      aspectRatios: _intList(json['aspect_ratios']),
      rimDiameters: _intList(json['rim_diameters']),
      seasons: _stringList(json['seasons']),
    );
  }
}

class SortOptionModel {
  final String key;
  final String title;

  const SortOptionModel({
    required this.key,
    required this.title,
  });

  factory SortOptionModel.fromJson(Map<String, dynamic> json) {
    return SortOptionModel(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}

class VehicleMakeFilterModel {
  final int? id;
  final String name;

  const VehicleMakeFilterModel({
    this.id,
    required this.name,
  });

  factory VehicleMakeFilterModel.fromJson(Map<String, dynamic> json) {
    return VehicleMakeFilterModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

class VehicleModelFilterModel {
  final int? id;
  final int? makeId;
  final String name;

  const VehicleModelFilterModel({
    this.id,
    this.makeId,
    required this.name,
  });

  factory VehicleModelFilterModel.fromJson(Map<String, dynamic> json) {
    return VehicleModelFilterModel(
      id: _toInt(json['id']),
      makeId: _toInt(json['make_id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

class MarketplaceFilterState {
  int? categoryId;
  String? productType;
  String? brand;
  String? search;
  double? minPrice;
  double? maxPrice;
  int? makeId;
  int? modelId;
  int? year;
  String? tireSize;
  int? width;
  int? aspectRatio;
  int? rimDiameter;
  int? inStock;
  String? sort;

  MarketplaceFilterState({
    this.categoryId,
    this.productType,
    this.brand,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.makeId,
    this.modelId,
    this.year,
    this.tireSize,
    this.width,
    this.aspectRatio,
    this.rimDiameter,
    this.inStock,
    this.sort,
  });

  Map<String, dynamic> toQuery() {
    return {
      if (categoryId != null) 'category_id': categoryId,
      if (productType != null && productType!.isNotEmpty)
        'product_type': productType,
      if (brand != null && brand!.isNotEmpty) 'brand': brand,
      if (search != null && search!.isNotEmpty) 'search': search,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (makeId != null) 'make_id': makeId,
      if (modelId != null) 'model_id': modelId,
      if (year != null) 'year': year,
      if (tireSize != null && tireSize!.isNotEmpty) 'tire_size': tireSize,
      if (width != null) 'width': width,
      if (aspectRatio != null) 'aspect_ratio': aspectRatio,
      if (rimDiameter != null) 'rim_diameter': rimDiameter,
      if (inStock != null) 'in_stock': inStock,
      if (sort != null && sort!.isNotEmpty) 'sort': sort,
    };
  }

  void clearKeepingType() {
    final currentType = productType;

    categoryId = null;
    brand = null;
    search = null;
    minPrice = null;
    maxPrice = null;
    makeId = null;
    modelId = null;
    year = null;
    tireSize = null;
    width = null;
    aspectRatio = null;
    rimDiameter = null;
    inStock = null;
    sort = null;

    productType = currentType;
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

List<String> _stringList(dynamic value) {
  if (value is! List) return [];
  return value.map((e) => e.toString()).toList();
}

List<int> _intList(dynamic value) {
  if (value is! List) return [];
  return value
      .map((e) => _toInt(e))
      .whereType<int>()
      .toList();
}