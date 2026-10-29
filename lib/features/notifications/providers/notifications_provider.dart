import 'package:flutter/foundation.dart';

import '../data/models/notification_model.dart';
import '../data/services/notification_api_service.dart';

class NotificationsProvider
    extends ChangeNotifier {
  final NotificationApiService _apiService =
  NotificationApiService();

  List<CustomerNotificationModel>
  _notifications = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isMarkingAll = false;

  String? _errorMessage;

  int _currentPage = 1;
  int _lastPage = 1;

  List<CustomerNotificationModel>
  get notifications => _notifications;

  bool get isLoading => _isLoading;

  bool get isLoadingMore =>
      _isLoadingMore;

  bool get isMarkingAll =>
      _isMarkingAll;

  String? get errorMessage =>
      _errorMessage;

  bool get hasError =>
      _errorMessage != null;

  bool get hasMore =>
      _currentPage < _lastPage;

  int get unreadCount =>
      _notifications
          .where(
            (notification) =>
        !notification.isRead,
      )
          .length;

  Future<void> loadNotifications() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _apiService.getNotifications(
        page: 1,
        perPage: 20,
      );

      _notifications =
          result.notifications;

      _currentPage =
          result.currentPage;

      _lastPage =
          result.lastPage;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      final result =
      await _apiService.getNotifications(
        page: 1,
        perPage: 20,
      );

      _notifications =
          result.notifications;

      _currentPage =
          result.currentPage;

      _lastPage =
          result.lastPage;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading ||
        _isLoadingMore ||
        !hasMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage =
          _currentPage + 1;

      final result =
      await _apiService.getNotifications(
        page: nextPage,
        perPage: 20,
      );

      _notifications = [
        ..._notifications,
        ...result.notifications,
      ];

      _currentPage =
          result.currentPage;

      _lastPage =
          result.lastPage;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(
      CustomerNotificationModel notification,
      ) async {
    if (notification.isRead) {
      return true;
    }

    try {
      await _apiService.markAsRead(
        notification.id,
      );

      final index =
      _notifications.indexWhere(
            (item) =>
        item.id == notification.id,
      );

      if (index != -1) {
        _notifications[index] =
            _notifications[index].copyWith(
              isRead: true,
              readAt: DateTime.now(),
            );

        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    if (_isMarkingAll ||
        unreadCount == 0) {
      return false;
    }

    _isMarkingAll = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _apiService.markAllAsRead();

      final now = DateTime.now();

      _notifications =
          _notifications.map(
                (notification) {
              if (notification.isRead) {
                return notification;
              }

              return notification.copyWith(
                isRead: true,
                readAt: now,
              );
            },
          ).toList();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _isMarkingAll = false;
      notifyListeners();
    }
  }
}