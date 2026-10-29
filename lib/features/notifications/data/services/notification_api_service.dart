import 'package:dio/dio.dart';

import '../../../../core/constants/url_api.dart';
import '../../../../data/remote/api_client.dart';
import '../models/notification_model.dart';

class NotificationPageResult {
  final List<CustomerNotificationModel>
  notifications;

  final int currentPage;
  final int lastPage;

  const NotificationPageResult({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore =>
      currentPage < lastPage;
}

class NotificationApiService {
  final ApiClient _apiClient = ApiClient();

  Future<NotificationPageResult>
  getNotifications({
    int page = 1,
    int perPage = 20,
    bool? isRead,
  }) async {
    final Response response =
    await _apiClient.get(
      UrlApi.customerNotifications,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (isRead != null)
          'is_read': isRead ? 1 : 0,
      },
    );

    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw 'Invalid notifications response.';
    }

    if (body['status'] != true) {
      throw body['message']?.toString() ??
          'Failed to load notifications.';
    }

    final payload = body['data'];

    if (payload is! Map<String, dynamic>) {
      throw 'Invalid notifications data.';
    }

    final rawNotifications =
    payload['data'];

    final notifications =
    <CustomerNotificationModel>[];

    if (rawNotifications is List) {
      for (final item in rawNotifications) {
        if (item is Map) {
          notifications.add(
            CustomerNotificationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return NotificationPageResult(
      notifications: notifications,
      currentPage:
      _toInt(payload['current_page']) ??
          page,
      lastPage:
      _toInt(payload['last_page']) ?? 1,
    );
  }

  Future<void> markAsRead(
      int notificationId,
      ) async {
    final Response response =
    await _apiClient.post(
      UrlApi.markCustomerNotificationRead(
        notificationId,
      ),
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true) {
      return;
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to mark notification as read.'
        : 'Failed to mark notification as read.';
  }

  Future<int> markAllAsRead() async {
    final Response response =
    await _apiClient.post(
      UrlApi.customerNotificationsReadAll,
    );

    final body = response.data;

    if (body is Map<String, dynamic> &&
        body['status'] == true) {
      final data = body['data'];

      if (data is Map<String, dynamic>) {
        return _toInt(
          data['updated_count'],
        ) ??
            0;
      }

      return 0;
    }

    throw body is Map<String, dynamic>
        ? body['message']?.toString() ??
        'Failed to mark notifications as read.'
        : 'Failed to mark notifications as read.';
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(
      value.toString(),
    );
  }
}