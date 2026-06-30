import '../../../vehicles/data/models/vehicle_model.dart';
import 'product_model.dart';

class CartModel {
  final int? id;
  final int? userId;
  final int? vehicleId;
  final int? vendorId;
  final String currency;
  final List<CartItemModel> items;
  final VehicleModel? vehicle;

  const CartModel({
    this.id,
    this.userId,
    this.vehicleId,
    this.vendorId,
    this.currency = 'USD',
    this.items = const [],
    this.vehicle,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      vehicleId: _toInt(json['vehicle_id']),
      vendorId: _toInt(json['vendor_id']),
      currency: json['currency']?.toString() ?? 'USD',
      items: json['items'] is List
          ? (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(CartItemModel.fromJson)
          .toList()
          : [],
      vehicle: json['vehicle'] is Map<String, dynamic>
          ? VehicleModel.fromJson(json['vehicle'])
          : null,
    );
  }

  int get itemsCount {
    return items.fold(0, (sum, item) => sum + item.qty);
  }

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.lineTotal);
  }
}

class CartItemModel {
  final int? id;
  final int? cartId;
  final int? productId;
  final int qty;
  final double unitPrice;
  final ProductModel? product;

  const CartItemModel({
    this.id,
    this.cartId,
    this.productId,
    this.qty = 0,
    this.unitPrice = 0,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: _toInt(json['id']),
      cartId: _toInt(json['cart_id']),
      productId: _toInt(json['product_id']),
      qty: _toInt(json['qty']) ?? 0,
      unitPrice: _toDouble(json['unit_price']) ?? 0,
      product: json['product'] is Map<String, dynamic>
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }

  double get lineTotal => qty * unitPrice;
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