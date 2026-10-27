class VehicleModel {
  final int? id;
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
  final int? mileage;
  final String? tireSize;
  final bool isPrimary;
  final String? status;
  final String? makeName;
  final String? modelName;

  const VehicleModel({
    this.id,
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
    this.mileage,
    this.tireSize,
    this.isPrimary = false,
    this.status,
    this.makeName,
    this.modelName,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final make = json['make'];
    final model = json['model'];
    return VehicleModel(
      id: _toInt(json['id']),
      makeId: _toInt(json['make_id']) ??
          (make is Map ? _toInt(make['id']) : null),
      modelId: _toInt(json['model_id']) ??
          (model is Map ? _toInt(model['id']) : null),
      year: _toInt(json['year']),
      trimName: json['trim_name']?.toString(),
      engine: json['engine']?.toString(),
      fuelType: json['fuel_type']?.toString(),
      transmission: json['transmission']?.toString(),
      color: json['color']?.toString(),
      vin: json['vin']?.toString(),
      plateNumber: json['plate_number']?.toString(),
      mileage: _toInt(json['mileage']),
      tireSize: json['tire_size']?.toString(),
      isPrimary: json['is_primary'] == true ||
          json['is_primary'] == 1 ||
          json['is_primary'] == '1',
      status: json['status']?.toString(),
      makeName: make is Map ? make['name']?.toString() : null,
      modelName: model is Map ? model['name']?.toString() : null,
    );
  }

  String get displayName {
    final parts = [
      if (year != null) year.toString(),
      if (makeName != null) makeName,
      if (modelName != null) modelName,
      if (trimName != null) trimName,
    ];
    return parts.whereType<String>().where((e) => e.isNotEmpty).join(' ');
  }

  String get details {
    final parts = [
      if (mileage != null) '$mileage miles',
      if (plateNumber != null) 'Plate: $plateNumber',
    ];
    return parts.join(' • ');
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
