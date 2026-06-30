class ProductModel {
  final int? id;
  final int? vendorId;
  final int? categoryId;
  final String productType;
  final String name;
  final String? sku;
  final String? brand;
  final String? shortDescription;
  final String? description;
  final double price;
  final double? compareAtPrice;
  final int stockQty;
  final bool isActive;
  final ProductImageModel? primaryImage;
  final List<ProductImageModel> images;
  final TireSpecModel? tireSpec;
  final List<ProductFitmentModel> fitments;

  const ProductModel({
    this.id,
    this.vendorId,
    this.categoryId,
    this.productType = 'part',
    required this.name,
    this.sku,
    this.brand,
    this.shortDescription,
    this.description,
    this.price = 0,
    this.compareAtPrice,
    this.stockQty = 0,
    this.isActive = true,
    this.primaryImage,
    this.images = const [],
    this.tireSpec,
    this.fitments = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _toInt(json['id']),
      vendorId: _toInt(json['vendor_id']),
      categoryId: _toInt(json['category_id']),
      productType: json['product_type']?.toString() ?? 'part',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString(),
      brand: json['brand']?.toString(),
      shortDescription: json['short_description']?.toString(),
      description: json['description']?.toString(),
      price: _toDouble(json['price']) ?? 0,
      compareAtPrice: _toDouble(json['compare_at_price']),
      stockQty: _toInt(json['stock_qty']) ?? 0,
      isActive: _toBool(json['is_active']),
      primaryImage: json['primary_image'] is Map<String, dynamic>
          ? ProductImageModel.fromJson(json['primary_image'])
          : null,
      images: json['images'] is List
          ? (json['images'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ProductImageModel.fromJson)
          .toList()
          : [],
      tireSpec: json['tire_spec'] is Map<String, dynamic>
          ? TireSpecModel.fromJson(json['tire_spec'])
          : null,
      fitments: json['fitments'] is List
          ? (json['fitments'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ProductFitmentModel.fromJson)
          .toList()
          : [],
    );
  }

  String get imageUrl => primaryImage?.imageUrl ?? '';

  bool get isTire => productType == 'tire';
  bool get isInStock => stockQty > 0;
}

class ProductImageModel {
  final int? id;
  final int? productId;
  final String? imagePath;
  final String? imageUrl;
  final int sortOrder;
  final bool isPrimary;

  const ProductImageModel({
    this.id,
    this.productId,
    this.imagePath,
    this.imageUrl,
    this.sortOrder = 0,
    this.isPrimary = false,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: _toInt(json['id']),
      productId: _toInt(json['product_id']),
      imagePath: json['image_path']?.toString(),
      imageUrl: json['image_url']?.toString(),
      sortOrder: _toInt(json['sort_order']) ?? 0,
      isPrimary: _toBool(json['is_primary']),
    );
  }
}

class TireSpecModel {
  final int? width;
  final int? aspectRatio;
  final int? rimDiameter;
  final String? loadIndex;
  final String? speedRating;
  final String? season;
  final bool runFlat;
  final String? treadType;

  const TireSpecModel({
    this.width,
    this.aspectRatio,
    this.rimDiameter,
    this.loadIndex,
    this.speedRating,
    this.season,
    this.runFlat = false,
    this.treadType,
  });

  factory TireSpecModel.fromJson(Map<String, dynamic> json) {
    return TireSpecModel(
      width: _toInt(json['width']),
      aspectRatio: _toInt(json['aspect_ratio']),
      rimDiameter: _toInt(json['rim_diameter']),
      loadIndex: json['load_index']?.toString(),
      speedRating: json['speed_rating']?.toString(),
      season: json['season']?.toString(),
      runFlat: _toBool(json['run_flat']),
      treadType: json['tread_type']?.toString(),
    );
  }

  String get displaySize {
    if (width == null || aspectRatio == null || rimDiameter == null) {
      return '';
    }

    return '$width/$aspectRatio R$rimDiameter';
  }
}

class ProductFitmentModel {
  final int? id;
  final int? yearFrom;
  final int? yearTo;
  final String? trimName;
  final String? engine;
  final String? notes;
  final String? makeName;
  final String? modelName;

  const ProductFitmentModel({
    this.id,
    this.yearFrom,
    this.yearTo,
    this.trimName,
    this.engine,
    this.notes,
    this.makeName,
    this.modelName,
  });

  factory ProductFitmentModel.fromJson(Map<String, dynamic> json) {
    return ProductFitmentModel(
      id: _toInt(json['id']),
      yearFrom: _toInt(json['year_from']),
      yearTo: _toInt(json['year_to']),
      trimName: json['trim_name']?.toString(),
      engine: json['engine']?.toString(),
      notes: json['notes']?.toString(),
      makeName: json['make'] is Map ? json['make']['name']?.toString() : null,
      modelName:
      json['model'] is Map ? json['model']['name']?.toString() : null,
    );
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

bool _toBool(dynamic value) {
  return value == true || value == 1 || value == '1' || value == 'true';
}