import '../../../vehicles/data/models/vehicle_model.dart';

class RepairHomeModel {
  final VehicleModel? primaryVehicle;
  final List<RepairServiceCategoryModel> serviceCategories;
  final List<RepairServiceModel> popularServices;
  final List<RepairWorkshopModel> repairWorkshops;
  final List<RepairWorkshopModel> bodyRepairWorkshops;
  final List<RepairRequestModel> recentRequests;

  const RepairHomeModel({
    this.primaryVehicle,
    this.serviceCategories = const [],
    this.popularServices = const [],
    this.repairWorkshops = const [],
    this.bodyRepairWorkshops = const [],
    this.recentRequests = const [],
  });

  factory RepairHomeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RepairHomeModel();

    return RepairHomeModel(
      primaryVehicle: json['primary_vehicle'] is Map<String, dynamic>
          ? VehicleModel.fromJson(json['primary_vehicle'])
          : null,
      serviceCategories: json['service_categories'] is List
          ? (json['service_categories'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RepairServiceCategoryModel.fromJson)
          .toList()
          : [],
      popularServices: json['popular_services'] is List
          ? (json['popular_services'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RepairServiceModel.fromJson)
          .toList()
          : [],
      repairWorkshops: json['repair_workshops'] is List
          ? (json['repair_workshops'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RepairWorkshopModel.fromJson)
          .toList()
          : [],
      bodyRepairWorkshops: json['body_repair_workshops'] is List
          ? (json['body_repair_workshops'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RepairWorkshopModel.fromJson)
          .toList()
          : [],
      recentRequests: json['recent_requests'] is List
          ? (json['recent_requests'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RepairRequestModel.fromJson)
          .toList()
          : [],
    );
  }
}

class RepairServiceCategoryModel {
  final int? id;
  final String name;
  final String? slug;
  final String? serviceType;
  final String? icon;

  const RepairServiceCategoryModel({
    this.id,
    required this.name,
    this.slug,
    this.serviceType,
    this.icon,
  });

  factory RepairServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return RepairServiceCategoryModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      serviceType: json['service_type']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}

class RepairServiceModel {
  final int? id;
  final int? categoryId;
  final String name;
  final String? slug;
  final String? serviceType;
  final String? description;
  final double? basePrice;

  const RepairServiceModel({
    this.id,
    this.categoryId,
    required this.name,
    this.slug,
    this.serviceType,
    this.description,
    this.basePrice,
  });

  factory RepairServiceModel.fromJson(Map<String, dynamic> json) {
    return RepairServiceModel(
      id: _toInt(json['id']),
      categoryId: _toInt(json['category_id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      serviceType: json['service_type']?.toString(),
      description: json['description']?.toString(),
      basePrice: _toDouble(json['base_price']),
    );
  }
}

class RepairWorkshopModel {
  final int? id;
  final String branchName;
  final int? vendorId;
  final String? vendorName;
  final double? distanceMiles;
  final double? rating;
  final int reviewsCount;
  final String? servicesText;
  final String? nextAvailableSlot;
  final String? tag;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool offersPickupDropoff;
  final bool offersRoadside;

  const RepairWorkshopModel({
    this.id,
    required this.branchName,
    this.vendorId,
    this.vendorName,
    this.distanceMiles,
    this.rating,
    this.reviewsCount = 0,
    this.servicesText,
    this.nextAvailableSlot,
    this.tag,
    this.address,
    this.latitude,
    this.longitude,
    this.offersPickupDropoff = false,
    this.offersRoadside = false,
  });

  factory RepairWorkshopModel.fromJson(Map<String, dynamic> json) {
    return RepairWorkshopModel(
      id: _toInt(json['id']),
      branchName: json['branch_name']?.toString() ?? '',
      vendorId: _toInt(json['vendor_id']),
      vendorName: json['vendor_name']?.toString(),
      distanceMiles: _toDouble(json['distance_miles']),
      rating: _toDouble(json['rating']),
      reviewsCount: _toInt(json['reviews_count']) ?? 0,
      servicesText: json['services_text']?.toString(),
      nextAvailableSlot: json['next_available_slot']?.toString(),
      tag: json['tag']?.toString(),
      address: json['address']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      offersPickupDropoff: _toBool(json['offers_pickup_dropoff']),
      offersRoadside: _toBool(json['offers_roadside']),
    );
  }
}

class RepairRequestModel {
  final int? id;
  final String? requestNumber;
  final int? vehicleId;
  final int? branchId;
  final int? serviceId;
  final String? issueTitle;
  final String? issueDescription;
  final String status;
  final String paymentStatus;
  final String? createdAt;

  const RepairRequestModel({
    this.id,
    this.requestNumber,
    this.vehicleId,
    this.branchId,
    this.serviceId,
    this.issueTitle,
    this.issueDescription,
    this.status = '',
    this.paymentStatus = '',
    this.createdAt,
  });

  factory RepairRequestModel.fromJson(Map<String, dynamic> json) {
    return RepairRequestModel(
      id: _toInt(json['id']),
      requestNumber: json['request_number']?.toString(),
      vehicleId: _toInt(json['vehicle_id']),
      branchId: _toInt(json['branch_id']),
      serviceId: _toInt(json['service_id']),
      issueTitle: json['issue_title']?.toString(),
      issueDescription: json['issue_description']?.toString(),
      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }

  String get title => issueTitle ?? requestNumber ?? 'Repair Request';
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