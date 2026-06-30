class AddressModel {
  final int? id;
  final String? label;
  final String? fullName;
  final String? phone;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final bool isDefault;

  const AddressModel({
    this.id,
    this.label,
    this.fullName,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: _toInt(json['id']),
      label: json['label']?.toString(),
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      addressLine1: json['address_line_1']?.toString() ??
          json['address_line1']?.toString(),
      addressLine2: json['address_line_2']?.toString() ??
          json['address_line2']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      postalCode: json['postal_code']?.toString(),
      country: json['country']?.toString(),
      isDefault: json['is_default'] == true ||
          json['is_default'] == 1 ||
          json['is_default'] == '1',
    );
  }

  String get title {
    if ((label ?? '').isNotEmpty) return label!;
    if ((fullName ?? '').isNotEmpty) return fullName!;
    return 'Address';
  }

  String get fullAddress {
    return [
      addressLine1,
      addressLine2,
      city,
      state,
      postalCode,
      country,
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}