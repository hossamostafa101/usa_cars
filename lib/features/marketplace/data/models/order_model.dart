class OrderModel {
  final int? id;
  final String? orderNumber;

  final int? userId;
  final int? vendorId;
  final int? vehicleId;
  final int? billingAddressId;
  final int? shippingAddressId;

  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double shippingAmount;
  final double totalAmount;

  final String paymentStatus;
  final String orderStatus;

  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  final List<OrderItemModel> items;
  final OrderVendorModel? vendor;
  final OrderVehicleModel? vehicle;

  // Keep these raw until we have non-null runtime samples.
  final Map<String, dynamic>? billingAddress;
  final Map<String, dynamic>? shippingAddress;
  final Map<String, dynamic>? shipment;

  final List<Map<String, dynamic>> payments;
  final List<Map<String, dynamic>> statusLogs;

  const OrderModel({
    this.id,
    this.orderNumber,
    this.userId,
    this.vendorId,
    this.vehicleId,
    this.billingAddressId,
    this.shippingAddressId,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.taxAmount = 0,
    this.shippingAmount = 0,
    this.totalAmount = 0,
    this.paymentStatus = '',
    this.orderStatus = '',
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.vendor,
    this.vehicle,
    this.billingAddress,
    this.shippingAddress,
    this.shipment,
    this.payments = const [],
    this.statusLogs = const [],
  });

  factory OrderModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderModel(
      id: _toInt(
        json['id'],
      ),
      orderNumber:
      json['order_number']?.toString(),

      userId: _toInt(
        json['user_id'],
      ),
      vendorId: _toInt(
        json['vendor_id'],
      ),
      vehicleId: _toInt(
        json['vehicle_id'],
      ),
      billingAddressId: _toInt(
        json['billing_address_id'],
      ),
      shippingAddressId: _toInt(
        json['shipping_address_id'],
      ),

      subtotal:
      _toDouble(
        json['subtotal'],
      ) ??
          0,
      discountAmount:
      _toDouble(
        json['discount_amount'],
      ) ??
          0,
      taxAmount:
      _toDouble(
        json['tax_amount'],
      ) ??
          0,
      shippingAmount:
      _toDouble(
        json['shipping_amount'],
      ) ??
          0,
      totalAmount:
      _toDouble(
        json['total_amount'],
      ) ??
          0,

      paymentStatus:
      json['payment_status']
          ?.toString() ??
          '',
      orderStatus:
      json['order_status']
          ?.toString() ??
          '',

      notes:
      json['notes']?.toString(),
      createdAt:
      json['created_at']?.toString(),
      updatedAt:
      json['updated_at']?.toString(),

      items: json['items'] is List
          ? (json['items'] as List)
          .whereType<
          Map<String, dynamic>>()
          .map(
        OrderItemModel.fromJson,
      )
          .toList()
          : const [],

      vendor:
      json['vendor']
      is Map<String, dynamic>
          ? OrderVendorModel.fromJson(
        json['vendor'],
      )
          : null,

      vehicle:
      json['vehicle']
      is Map<String, dynamic>
          ? OrderVehicleModel.fromJson(
        json['vehicle'],
      )
          : null,

      billingAddress:
      json['billing_address']
      is Map<String, dynamic>
          ? Map<String, dynamic>.from(
        json['billing_address'],
      )
          : null,

      shippingAddress:
      json['shipping_address']
      is Map<String, dynamic>
          ? Map<String, dynamic>.from(
        json['shipping_address'],
      )
          : null,

      shipment:
      json['shipment']
      is Map<String, dynamic>
          ? Map<String, dynamic>.from(
        json['shipment'],
      )
          : null,

      payments:
      json['payments'] is List
          ? (json['payments'] as List)
          .whereType<
          Map<String, dynamic>>()
          .map(
            (e) =>
        Map<String, dynamic>
            .from(e),
      )
          .toList()
          : const [],

      statusLogs:
      json['status_logs'] is List
          ? (json['status_logs'] as List)
          .whereType<
          Map<String, dynamic>>()
          .map(
            (e) =>
        Map<String, dynamic>
            .from(e),
      )
          .toList()
          : const [],
    );
  }

  bool get canCancel =>
      orderStatus == 'pending' ||
          orderStatus == 'confirmed';
}

class OrderItemModel {
  final int? id;
  final int? orderId;
  final int? productId;

  final String productName;
  final String? sku;

  final int qty;
  final double unitPrice;
  final double totalPrice;

  final String? createdAt;

  final OrderProductModel? product;

  const OrderItemModel({
    this.id,
    this.orderId,
    this.productId,
    this.productName = '',
    this.sku,
    this.qty = 0,
    this.unitPrice = 0,
    this.totalPrice = 0,
    this.createdAt,
    this.product,
  });

  factory OrderItemModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderItemModel(
      id: _toInt(
        json['id'],
      ),
      orderId: _toInt(
        json['order_id'],
      ),
      productId: _toInt(
        json['product_id'],
      ),
      productName:
      json['product_name']
          ?.toString() ??
          '',
      sku:
      json['sku']?.toString(),
      qty:
      _toInt(
        json['qty'],
      ) ??
          0,
      unitPrice:
      _toDouble(
        json['unit_price'],
      ) ??
          0,
      totalPrice:
      _toDouble(
        json['total_price'],
      ) ??
          0,
      createdAt:
      json['created_at']?.toString(),
      product:
      json['product']
      is Map<String, dynamic>
          ? OrderProductModel.fromJson(
        json['product'],
      )
          : null,
    );
  }
}

class OrderProductModel {
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
  final int minStockAlert;

  final bool isActive;
  final bool requiresVehicleMatch;

  final double? shippingWeightLbs;

  final Map<String, dynamic>? primaryImage;

  const OrderProductModel({
    this.id,
    this.vendorId,
    this.categoryId,
    this.productType = '',
    this.name = '',
    this.sku,
    this.brand,
    this.shortDescription,
    this.description,
    this.price = 0,
    this.compareAtPrice,
    this.stockQty = 0,
    this.minStockAlert = 0,
    this.isActive = false,
    this.requiresVehicleMatch = false,
    this.shippingWeightLbs,
    this.primaryImage,
  });

  factory OrderProductModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderProductModel(
      id: _toInt(
        json['id'],
      ),
      vendorId: _toInt(
        json['vendor_id'],
      ),
      categoryId: _toInt(
        json['category_id'],
      ),
      productType:
      json['product_type']
          ?.toString() ??
          '',
      name:
      json['name']?.toString() ??
          '',
      sku:
      json['sku']?.toString(),
      brand:
      json['brand']?.toString(),
      shortDescription:
      json['short_description']
          ?.toString(),
      description:
      json['description']?.toString(),
      price:
      _toDouble(
        json['price'],
      ) ??
          0,
      compareAtPrice:
      _toDouble(
        json['compare_at_price'],
      ),
      stockQty:
      _toInt(
        json['stock_qty'],
      ) ??
          0,
      minStockAlert:
      _toInt(
        json['min_stock_alert'],
      ) ??
          0,
      isActive:
      _toBool(
        json['is_active'],
      ),
      requiresVehicleMatch:
      _toBool(
        json['requires_vehicle_match'],
      ),
      shippingWeightLbs:
      _toDouble(
        json['shipping_weight_lbs'],
      ),
      primaryImage:
      json['primary_image']
      is Map<String, dynamic>
          ? Map<String, dynamic>.from(
        json['primary_image'],
      )
          : null,
    );
  }
}

class OrderVendorModel {
  final int? id;
  final int? userId;

  final String? businessName;
  final String? businessType;

  final String? description;
  final String? supportEmail;
  final String? supportPhone;

  final bool isVerified;
  final String? verificationStatus;

  final double averageRating;
  final int totalReviews;

  const OrderVendorModel({
    this.id,
    this.userId,
    this.businessName,
    this.businessType,
    this.description,
    this.supportEmail,
    this.supportPhone,
    this.isVerified = false,
    this.verificationStatus,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  factory OrderVendorModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderVendorModel(
      id: _toInt(
        json['id'],
      ),
      userId: _toInt(
        json['user_id'],
      ),
      businessName:
      json['business_name']
          ?.toString(),
      businessType:
      json['business_type']
          ?.toString(),
      description:
      json['description']
          ?.toString(),
      supportEmail:
      json['support_email']
          ?.toString(),
      supportPhone:
      json['support_phone']
          ?.toString(),
      isVerified:
      _toBool(
        json['is_verified'],
      ),
      verificationStatus:
      json['verification_status']
          ?.toString(),
      averageRating:
      _toDouble(
        json['average_rating'],
      ) ??
          0,
      totalReviews:
      _toInt(
        json['total_reviews'],
      ) ??
          0,
    );
  }
}

class OrderVehicleModel {
  final int? id;
  final int? userId;
  final int? makeId;
  final int? modelId;

  final int? year;

  final String? trimName;
  final String? engine;
  final String? fuelType;
  final String? transmission;

  final String? color;
  final String? vin;
  final String? plateNumber;

  final int mileage;

  final String? tireSize;

  final bool isPrimary;
  final String? status;

  const OrderVehicleModel({
    this.id,
    this.userId,
    this.makeId,
    this.modelId,
    this.year,
    this.trimName,
    this.engine,
    this.fuelType,
    this.transmission,
    this.color,
    this.vin,
    this.plateNumber,
    this.mileage = 0,
    this.tireSize,
    this.isPrimary = false,
    this.status,
  });

  factory OrderVehicleModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderVehicleModel(
      id: _toInt(
        json['id'],
      ),
      userId: _toInt(
        json['user_id'],
      ),
      makeId: _toInt(
        json['make_id'],
      ),
      modelId: _toInt(
        json['model_id'],
      ),
      year: _toInt(
        json['year'],
      ),
      trimName:
      json['trim_name']?.toString(),
      engine:
      json['engine']?.toString(),
      fuelType:
      json['fuel_type']?.toString(),
      transmission:
      json['transmission']
          ?.toString(),
      color:
      json['color']?.toString(),
      vin:
      json['vin']?.toString(),
      plateNumber:
      json['plate_number']
          ?.toString(),
      mileage:
      _toInt(
        json['mileage'],
      ) ??
          0,
      tireSize:
      json['tire_size']?.toString(),
      isPrimary:
      _toBool(
        json['is_primary'],
      ),
      status:
      json['status']?.toString(),
    );
  }
}

class PaymentModel {
  final int? id;
  final double amount;
  final String currency;
  final String paymentType;
  final String status;

  const PaymentModel({
    this.id,
    this.amount = 0,
    this.currency = 'USD',
    this.paymentType = '',
    this.status = '',
  });

  factory PaymentModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PaymentModel(
      id: _toInt(
        json['id'],
      ),
      amount:
      _toDouble(
        json['amount'],
      ) ??
          0,
      currency:
      json['currency']?.toString() ??
          'USD',
      paymentType:
      json['payment_type']
          ?.toString() ??
          '',
      status:
      json['status']?.toString() ??
          '',
    );
  }
}

int? _toInt(
    dynamic value,
    ) {
  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  return int.tryParse(
    value.toString(),
  );
}

double? _toDouble(
    dynamic value,
    ) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value.toString(),
  );
}

bool _toBool(
    dynamic value,
    ) {
  return value == true ||
      value == 1 ||
      value == '1' ||
      value == 'true';
}