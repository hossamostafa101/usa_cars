class PartRequestVehicleOption {
  final int id;
  final int? year;
  final String? makeName;
  final String? modelName;
  final String? trimName;
  final String? engine;
  final bool isPrimary;

  const PartRequestVehicleOption({
    required this.id,
    this.year,
    this.makeName,
    this.modelName,
    this.trimName,
    this.engine,
    this.isPrimary = false,
  });

  factory PartRequestVehicleOption.fromJson(
      Map<String, dynamic> json,
      ) {
    final make = json['make'];
    final model = json['model'];

    return PartRequestVehicleOption(
      id: _toInt(json['id']) ?? 0,
      year: _toInt(json['year']),
      makeName: make is Map
          ? make['name']?.toString()
          : json['make_name']?.toString(),
      modelName: model is Map
          ? model['name']?.toString()
          : json['model_name']?.toString(),
      trimName: json['trim_name']?.toString(),
      engine: json['engine']?.toString(),
      isPrimary: _toBool(json['is_primary']),
    );
  }

  String get displayName {
    return [
      year?.toString(),
      makeName,
      modelName,
      trimName,
    ]
        .whereType<String>()
        .where((e) => e.trim().isNotEmpty)
        .join(' ');
  }
}

class PartRequestAddressOption {
  final int id;
  final String? label;
  final String addressLine1;
  final String city;
  final String state;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const PartRequestAddressOption({
    required this.id,
    this.label,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory PartRequestAddressOption.fromJson(
      Map<String, dynamic> json,
      ) {
    return PartRequestAddressOption(
      id: _toInt(json['id']) ?? 0,
      label: json['label']?.toString(),
      addressLine1:
      json['address_line_1']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode:
      json['postal_code']?.toString() ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      isDefault: _toBool(json['is_default']),
    );
  }

  bool get hasCoordinates =>
      latitude != null && longitude != null;

  String get displayName {
    final title =
    label?.trim().isNotEmpty == true ? '$label — ' : '';

    return '$title$addressLine1, $city, $state';
  }
}

class PartQuotationModel {
  final int id;
  final int vendorId;
  final int? branchId;

  final String? vendorName;
  final String? branchName;

  final String? brand;
  final String? partNumber;
  final String conditionType;

  final double unitPrice;
  final int quantityAvailable;
  final double deliveryFee;

  final int? estimatedDeliveryDays;
  final String? warrantyText;
  final String? notes;

  final String status;

  const PartQuotationModel({
    required this.id,
    required this.vendorId,
    this.branchId,
    this.vendorName,
    this.branchName,
    this.brand,
    this.partNumber,
    required this.conditionType,
    required this.unitPrice,
    required this.quantityAvailable,
    required this.deliveryFee,
    this.estimatedDeliveryDays,
    this.warrantyText,
    this.notes,
    required this.status,
  });

  factory PartQuotationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final vendor = json['vendor'];
    final branch = json['branch'];

    return PartQuotationModel(
      id: _toInt(json['id']) ?? 0,
      vendorId: _toInt(json['vendor_id']) ?? 0,
      branchId: _toInt(json['branch_id']),
      vendorName: vendor is Map
          ? vendor['business_name']?.toString()
          : null,
      branchName: branch is Map
          ? branch['branch_name']?.toString()
          : null,
      brand: json['brand']?.toString(),
      partNumber: json['part_number']?.toString(),
      conditionType:
      json['condition_type']?.toString() ?? 'new',
      unitPrice: _toDouble(json['unit_price']) ?? 0,
      quantityAvailable:
      _toInt(json['quantity_available']) ?? 0,
      deliveryFee:
      _toDouble(json['delivery_fee']) ?? 0,
      estimatedDeliveryDays:
      _toInt(json['estimated_delivery_days']),
      warrantyText:
      json['warranty_text']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }

  double totalForQuantity(int quantity) {
    return (unitPrice * quantity) + deliveryFee;
  }
}

class PartRequestModel {
  final int id;
  final String requestNumber;

  final int vehicleId;
  final int categoryId;
  final int? addressId;

  final String quotationScope;
  final int quantity;

  final String? brandPreference;
  final String? notes;

  final String status;

  final int? selectedQuotationId;

  final String? vehicleName;
  final String? engine;

  final String? categoryName;
  final String? categoryGroup;
  final String? categoryRoot;

  final List<PartQuotationModel> quotations;
  final PartQuotationModel? selectedQuotation;

  const PartRequestModel({
    required this.id,
    required this.requestNumber,
    required this.vehicleId,
    required this.categoryId,
    this.addressId,
    required this.quotationScope,
    required this.quantity,
    this.brandPreference,
    this.notes,
    required this.status,
    this.selectedQuotationId,
    this.vehicleName,
    this.engine,
    this.categoryName,
    this.categoryGroup,
    this.categoryRoot,
    this.quotations = const [],
    this.selectedQuotation,
  });

  factory PartRequestModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final vehicle = json['vehicle'];
    final category = json['category'];

    String? vehicleName;
    String? engine;

    if (vehicle is Map) {
      final make = vehicle['make'];
      final model = vehicle['model'];

      final makeName =
      make is Map ? make['name']?.toString() : null;

      final modelName =
      model is Map ? model['name']?.toString() : null;

      vehicleName = [
        vehicle['year']?.toString(),
        makeName,
        modelName,
        vehicle['trim_name']?.toString(),
      ]
          .whereType<String>()
          .where((e) => e.trim().isNotEmpty)
          .join(' ');

      engine = vehicle['engine']?.toString();
    }

    String? categoryName;
    String? categoryGroup;
    String? categoryRoot;

    if (category is Map) {
      categoryName = category['name']?.toString();

      final parent = category['parent'];

      if (parent is Map) {
        categoryGroup = parent['name']?.toString();

        final root = parent['parent'];

        if (root is Map) {
          categoryRoot = root['name']?.toString();
        }
      }
    }

    final quotations = <PartQuotationModel>[];

    final quotationsJson = json['quotations'];

    if (quotationsJson is List) {
      for (final item in quotationsJson) {
        if (item is Map) {
          quotations.add(
            PartQuotationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    PartQuotationModel? selectedQuotation;

    final selectedJson = json['selected_quotation'];

    if (selectedJson is Map) {
      selectedQuotation =
          PartQuotationModel.fromJson(
            Map<String, dynamic>.from(selectedJson),
          );
    }

    return PartRequestModel(
      id: _toInt(json['id']) ?? 0,
      requestNumber:
      json['request_number']?.toString() ?? '',
      vehicleId: _toInt(json['vehicle_id']) ?? 0,
      categoryId: _toInt(json['category_id']) ?? 0,
      addressId: _toInt(json['address_id']),
      quotationScope:
      json['quotation_scope']?.toString() ??
          'anywhere',
      quantity: _toInt(json['quantity']) ?? 1,
      brandPreference:
      json['brand_preference']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? '',
      selectedQuotationId:
      _toInt(json['selected_quotation_id']),
      vehicleName: vehicleName,
      engine: engine,
      categoryName: categoryName,
      categoryGroup: categoryGroup,
      categoryRoot: categoryRoot,
      quotations: quotations,
      selectedQuotation: selectedQuotation,
    );
  }

  String get partPath {
    return [
      categoryRoot,
      categoryGroup,
      categoryName,
    ]
        .whereType<String>()
        .where((e) => e.trim().isNotEmpty)
        .join(' → ');
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

  if (value is num) return value.toDouble();

  return double.tryParse(value.toString());
}

bool _toBool(dynamic value) {
  if (value == true || value == 1 || value == '1') {
    return true;
  }

  return false;
}