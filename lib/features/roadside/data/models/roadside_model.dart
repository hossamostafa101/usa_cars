import '../../../vehicles/data/models/vehicle_model.dart';

class RoadsideHomeModel {
  final RoadsideRequestModel? activeRequest;
  final List<RoadsideServiceModel> services;
  final List<RoadsideRequestModel> recentRequests;
  final String averageEta;

  const RoadsideHomeModel({
    this.activeRequest,
    this.services = const [],
    this.recentRequests = const [],
    this.averageEta = '',
  });

  factory RoadsideHomeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RoadsideHomeModel();

    return RoadsideHomeModel(
      activeRequest: json['active_request'] is Map<String, dynamic>
          ? RoadsideRequestModel.fromJson(json['active_request'])
          : null,
      services: json['services'] is List
          ? (json['services'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RoadsideServiceModel.fromJson)
          .toList()
          : [],
      recentRequests: json['recent_requests'] is List
          ? (json['recent_requests'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RoadsideRequestModel.fromJson)
          .toList()
          : [],
      averageEta: json['average_eta']?.toString() ?? '',
    );
  }
}

class RoadsideServiceModel {
  final int? id;
  final String name;
  final String? slug;
  final String? icon;
  final String? estimatedEta;

  const RoadsideServiceModel({
    this.id,
    required this.name,
    this.slug,
    this.icon,
    this.estimatedEta,
  });

  factory RoadsideServiceModel.fromJson(Map<String, dynamic> json) {
    return RoadsideServiceModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      icon: json['icon']?.toString(),
      estimatedEta: json['estimated_eta']?.toString(),
    );
  }
}

class RoadsideRequestModel {
  final int? id;
  final String? requestNumber;
  final int? userId;
  final int? vehicleId;
  final int? serviceTypeId;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final String status;
  final String paymentStatus;
  final RoadsideServiceModel? serviceType;
  final VehicleModel? vehicle;

  const RoadsideRequestModel({
    this.id,
    this.requestNumber,
    this.userId,
    this.vehicleId,
    this.serviceTypeId,
    this.latitude,
    this.longitude,
    this.notes,
    this.status = '',
    this.paymentStatus = '',
    this.serviceType,
    this.vehicle,
  });

  factory RoadsideRequestModel.fromJson(Map<String, dynamic> json) {
    return RoadsideRequestModel(
      id: _toInt(json['id']),
      requestNumber: json['request_number']?.toString(),
      userId: _toInt(json['user_id']),
      vehicleId: _toInt(json['vehicle_id']),
      serviceTypeId: _toInt(json['service_type_id']),
      latitude: _toDouble(json['location_latitude']),
      longitude: _toDouble(json['location_longitude']),
      notes: json['issue_notes']?.toString(),
      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      serviceType: json['service_type'] is Map<String, dynamic>
          ? RoadsideServiceModel.fromJson(json['service_type'])
          : null,
      vehicle: json['vehicle'] is Map<String, dynamic>
          ? VehicleModel.fromJson(json['vehicle'])
          : null,
    );
  }

  String get title {
    return serviceType?.name ?? requestNumber ?? 'Roadside Request';
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


class RoadsideVendorModel {
  final int? id;
  final String branchName;
  final int? vendorId;
  final String? vendorName;
  final double? rating;
  final int reviewsCount;
  final double? distanceMiles;
  final double? basePrice;
  final double? pricePerMile;
  final int? estimatedEtaMinutes;
  final String? estimatedEta;
  final String? address;
  final double? latitude;
  final double? longitude;

  const RoadsideVendorModel({
    this.id,
    required this.branchName,
    this.vendorId,
    this.vendorName,
    this.rating,
    this.reviewsCount = 0,
    this.distanceMiles,
    this.basePrice,
    this.pricePerMile,
    this.estimatedEtaMinutes,
    this.estimatedEta,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory RoadsideVendorModel.fromJson(Map<String, dynamic> json) {
    return RoadsideVendorModel(
      id: _toInt(json['id']),
      branchName: json['branch_name']?.toString() ?? '',
      vendorId: _toInt(json['vendor_id']),
      vendorName: json['vendor_name']?.toString(),
      rating: _toDouble(json['rating']),
      reviewsCount: _toInt(json['reviews_count']) ?? 0,
      distanceMiles: _toDouble(json['distance_miles']),
      basePrice: _toDouble(json['base_price']),
      pricePerMile: _toDouble(json['price_per_mile']),
      estimatedEtaMinutes: _toInt(json['estimated_eta_minutes']),
      estimatedEta: json['estimated_eta']?.toString(),
      address: json['address']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }
}