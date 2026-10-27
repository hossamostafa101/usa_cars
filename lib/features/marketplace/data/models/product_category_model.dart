class ProductCategoryModel {
  final int? id;
  final int? parentId;
  final String name;
  final String? slug;
  final String? categoryType;
  final int productsCount;
  final int childrenCount;
  final List<ProductCategoryModel> children;

  const ProductCategoryModel({
    this.id,
    this.parentId,
    required this.name,
    this.slug,
    this.categoryType,
    this.productsCount = 0,
    this.childrenCount = 0,
    this.children = const [],
  });

  bool get isLeaf => childrenCount == 0;

  bool get hasChildren => childrenCount > 0;

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: _toInt(json['id']),
      parentId: _toInt(json['parent_id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      categoryType: json['category_type']?.toString(),
      productsCount: _toInt(json['products_count']) ?? 0,
      childrenCount: _toInt(json['children_count']) ?? 0,
      children: json['children'] is List
          ? (json['children'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ProductCategoryModel.fromJson)
          .toList()
          : [],
    );
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}