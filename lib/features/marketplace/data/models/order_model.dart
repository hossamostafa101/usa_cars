class OrderModel {
  final int? id;
  final String? orderNumber;
  final double subtotal;
  final double taxAmount;
  final double shippingAmount;
  final double totalAmount;
  final String paymentStatus;
  final String orderStatus;

  const OrderModel({
    this.id,
    this.orderNumber,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.shippingAmount = 0,
    this.totalAmount = 0,
    this.paymentStatus = '',
    this.orderStatus = '',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _toInt(json['id']),
      orderNumber: json['order_number']?.toString(),
      subtotal: _toDouble(json['subtotal']) ?? 0,
      taxAmount: _toDouble(json['tax_amount']) ?? 0,
      shippingAmount: _toDouble(json['shipping_amount']) ?? 0,
      totalAmount: _toDouble(json['total_amount']) ?? 0,
      paymentStatus: json['payment_status']?.toString() ?? '',
      orderStatus: json['order_status']?.toString() ?? '',
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

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _toInt(json['id']),
      amount: _toDouble(json['amount']) ?? 0,
      currency: json['currency']?.toString() ?? 'USD',
      paymentType: json['payment_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
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