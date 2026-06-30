
import 'package:talabatfresh/features/vehicles/data/models/vehicle_model.dart';
import 'package:talabatfresh/models/user_model.dart';

class CustomerHomeModel {
  final UserModel? user;
  final VehicleModel? primaryVehicle;
  final List<HomeBannerModel> banners;
  final List<QuickActionModel> quickActions;
  final List<FeaturedOfferModel> featuredOffers;
  final List<RecentActivityModel> recentActivities;
  final int unreadNotificationsCount;

  const CustomerHomeModel({
    this.user,
    this.primaryVehicle,
    this.banners = const [],
    this.quickActions = const [],
    this.featuredOffers = const [],
    this.recentActivities = const [],
    this.unreadNotificationsCount = 0,
  });

  factory CustomerHomeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CustomerHomeModel();

    return CustomerHomeModel(
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : null,

      primaryVehicle: json['primary_vehicle'] is Map<String, dynamic>
          ? VehicleModel.fromJson(json['primary_vehicle'])
          : null,

      banners: json['banners'] is List
          ? (json['banners'] as List)
          .whereType<Map<String, dynamic>>()
          .map(HomeBannerModel.fromJson)
          .toList()
          : [],

      quickActions: json['quick_actions'] is List
          ? (json['quick_actions'] as List)
          .whereType<Map<String, dynamic>>()
          .map(QuickActionModel.fromJson)
          .toList()
          : [],

      featuredOffers: json['featured_offers'] is List
          ? (json['featured_offers'] as List)
          .whereType<Map<String, dynamic>>()
          .map(FeaturedOfferModel.fromJson)
          .toList()
          : [],

      recentActivities: json['recent_activities'] is List
          ? (json['recent_activities'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RecentActivityModel.fromJson)
          .toList()
          : [],

      unreadNotificationsCount: _toInt(json['unread_notifications_count']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}


class HomeBannerModel {
  final int? id;
  final String? title;
  final String? subtitle;
  final String? imagePath;
  final String? actionType;
  final String? actionValue;
  final int sortOrder;

  const HomeBannerModel({
    this.id,
    this.title,
    this.subtitle,
    this.imagePath,
    this.actionType,
    this.actionValue,
    this.sortOrder = 0,
  });

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    return HomeBannerModel(
      id: _toInt(json['id']),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      imagePath: json['image_path']?.toString(),
      actionType: json['action_type']?.toString(),
      actionValue: json['action_value']?.toString(),
      sortOrder: _toInt(json['sort_order']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}


class QuickActionModel {
  final String key;
  final String title;
  final String subtitle;
  final String icon;
  final String route;

  const QuickActionModel({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
    );
  }
}


class FeaturedOfferModel {
  final int? id;
  final String? title;
  final String? description;
  final String? imagePath;
  final String? offerType;
  final String? discountText;
  final String? actionType;
  final String? actionValue;
  final int sortOrder;

  const FeaturedOfferModel({
    this.id,
    this.title,
    this.description,
    this.imagePath,
    this.offerType,
    this.discountText,
    this.actionType,
    this.actionValue,
    this.sortOrder = 0,
  });

  factory FeaturedOfferModel.fromJson(Map<String, dynamic> json) {
    return FeaturedOfferModel(
      id: _toInt(json['id']),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      imagePath: json['image_path']?.toString(),
      offerType: json['offer_type']?.toString(),
      discountText: json['discount_text']?.toString(),
      actionType: json['action_type']?.toString(),
      actionValue: json['action_value']?.toString(),
      sortOrder: _toInt(json['sort_order']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}


class RecentActivityModel {
  final String type;
  final int? id;
  final String title;
  final String status;
  final String? createdAt;

  const RecentActivityModel({
    required this.type,
    this.id,
    required this.title,
    required this.status,
    this.createdAt,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      type: json['type']?.toString() ?? '',
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}