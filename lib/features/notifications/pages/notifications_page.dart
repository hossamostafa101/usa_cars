import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/models/notification_model.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      NotificationsProvider()
        ..loadNotifications(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() =>
      _NotificationsViewState();
}

class _NotificationsViewState
    extends State<_NotificationsView> {
  static const Color orange = Color(0xFFF57C00);
  static const Color ink = Color(0xFF172033);
  static const Color background = Color(0xFFF5F6F8);
  static const Color muted = Color(0xFF8B929D);

  final ScrollController _scrollController =
  ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position =
        _scrollController.position;

    if (position.pixels >=
        position.maxScrollExtent - 250) {
      context
          .read<NotificationsProvider>()
          .loadMore();
    }
  }

  Future<void> _markAllRead() async {
    final provider =
    context.read<
        NotificationsProvider>();

    final success =
    await provider.markAllAsRead();

    if (!mounted || success) return;

    final message =
        provider.errorMessage;

    if (message == null ||
        message.trim().isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _openNotification(
      CustomerNotificationModel notification,
      ) async {
    final provider =
    context.read<
        NotificationsProvider>();

    CustomerNotificationModel
    currentNotification =
        notification;

    if (!notification.isRead) {
      final success =
      await provider.markAsRead(
        notification,
      );

      if (!mounted) return;

      if (!success) {
        final message =
            provider.errorMessage;

        if (message != null &&
            message.isNotEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
        }

        return;
      }

      currentNotification =
          notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
    }

    if (!mounted) return;

    _showNotificationDetails(
      currentNotification,
    );
  }

  void _showNotificationDetails(
      CustomerNotificationModel notification,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      builder: (sheetContext) {
        final icon =
        _notificationVisual(
          notification,
        );

        return SafeArea(
          top: false,
          child: Container(
            margin:
            const EdgeInsets.all(12),
            padding:
            const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(26),
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin:
                    const EdgeInsets.only(
                      bottom: 20,
                    ),
                    decoration:
                    BoxDecoration(
                      color: const Color(
                        0xFFD8DBE0,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        99,
                      ),
                    ),
                  ),
                ),

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _NotificationIcon(
                      icon: icon.icon,
                      color: icon.color,
                      size: 46,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification
                                .title,
                            style:
                            const TextStyle(
                              color: ink,
                              fontSize: 16,
                              height: 1.25,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          if (notification
                              .createdAt !=
                              null) ...[
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              _formatTime(
                                notification
                                    .createdAt,
                              ),
                              style:
                              const TextStyle(
                                color: muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(
                          sheetContext,
                        );
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                      color: const Color(
                        0xFF9AA1AC,
                      ),
                      visualDensity:
                      VisualDensity.compact,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 18,
                ),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFF7F8FA,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Text(
                    notification.body,
                    style:
                    const TextStyle(
                      color:
                      Color(0xFF4E5663),
                      fontSize: 12,
                      height: 1.55,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<
        NotificationsProvider>();

    final topInset =
        MediaQuery.of(context)
            .padding
            .top;

    return AnnotatedRegion<
        SystemUiOverlayStyle>(
      value:
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor:
        Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: background,
        body: Column(
          children: [
            _NotificationsHeader(
              topInset: topInset,
              unreadCount:
              provider.unreadCount,
              isMarkingAll:
              provider.isMarkingAll,
              onBack: () {
                Navigator.pop(context);
              },
              onMarkAll:
              _markAllRead,
            ),

            Expanded(
              child: _buildContent(
                provider,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      NotificationsProvider provider,
      ) {
    if (provider.isLoading &&
        provider.notifications.isEmpty) {
      return const _LoadingView();
    }

    if (provider.hasError &&
        provider.notifications.isEmpty) {
      return _ErrorState(
        message:
        provider.errorMessage ??
            'Could not load notifications.',
        onRetry:
        provider.loadNotifications,
      );
    }

    if (provider.notifications.isEmpty) {
      return RefreshIndicator(
        color: orange,
        onRefresh: provider.refresh,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.only(
            top: 90,
          ),
          children: const [
            _EmptyState(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: orange,
      onRefresh: provider.refresh,
      child: ListView.builder(
        controller:
        _scrollController,
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.fromLTRB(
          14,
          16,
          14,
          28,
        ),
        itemCount:
        provider.notifications.length +
            (provider.isLoadingMore
                ? 1
                : 0),
        itemBuilder:
            (context, index) {
          if (index >=
              provider
                  .notifications.length) {
            return const Padding(
              padding:
              EdgeInsets.symmetric(
                vertical: 18,
              ),
              child: Center(
                child:
                CircularProgressIndicator(
                  color: orange,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          final notification =
          provider
              .notifications[index];

          final previous =
          index == 0
              ? null
              : provider
              .notifications[
          index - 1
          ];

          final section =
          _sectionForDate(
            notification.createdAt,
          );

          final previousSection =
          previous == null
              ? null
              : _sectionForDate(
            previous.createdAt,
          );

          final showSection =
              section !=
                  previousSection;

          return Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              if (showSection) ...[
                Padding(
                  padding:
                  EdgeInsets.only(
                    left: 2,
                    top:
                    index == 0
                        ? 0
                        : 12,
                    bottom: 9,
                  ),
                  child: Text(
                    section,
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF747C88,
                      ),
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing: .3,
                    ),
                  ),
                ),
              ],

              Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 9,
                ),
                child:
                _NotificationCard(
                  notification:
                  notification,
                  onTap: () =>
                      _openNotification(
                        notification,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _sectionForDate(
      DateTime? value,
      ) {
    if (value == null) {
      return 'Earlier';
    }

    final date =
    value.toLocal();

    final now =
    DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final notificationDay =
    DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        today
            .difference(
          notificationDay,
        )
            .inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    if (difference < 7) {
      return 'Earlier this week';
    }

    return 'Earlier';
  }

  static String _formatTime(
      DateTime? value,
      ) {
    if (value == null) {
      return '';
    }

    final date =
    value.toLocal();

    final now =
    DateTime.now();

    final difference =
    now.difference(date);

    if (!difference.isNegative) {
      if (difference.inMinutes <
          1) {
        return 'Just now';
      }

      if (difference.inMinutes <
          60) {
        return '${difference.inMinutes} min ago';
      }

      if (difference.inHours <
          24) {
        return '${difference.inHours} hr ago';
      }

      if (difference.inDays ==
          1) {
        return 'Yesterday';
      }

      if (difference.inDays <
          7) {
        return '${difference.inDays} days ago';
      }
    }

    final day =
    date.day
        .toString()
        .padLeft(
      2,
      '0',
    );

    final month =
    date.month
        .toString()
        .padLeft(
      2,
      '0',
    );

    return '$day/$month/${date.year}';
  }

  static _NotificationVisualData
  _notificationVisual(
      CustomerNotificationModel notification,
      ) {
    final type =
    (notification.type ?? '')
        .toLowerCase();

    if (type.contains('order')) {
      return const _NotificationVisualData(
        icon:
        Icons.shopping_bag_outlined,
        color:
        Color(0xFF3975D5),
      );
    }

    if (type.contains('repair') ||
        type.contains('service')) {
      return const _NotificationVisualData(
        icon:
        Icons.build_circle_outlined,
        color:
        Color(0xFF7159C1),
      );
    }

    if (type.contains('roadside')) {
      return const _NotificationVisualData(
        icon:
        Icons
            .electric_bolt_rounded,
        color: orange,
      );
    }

    if (type.contains('part') ||
        type.contains('quote')) {
      return const _NotificationVisualData(
        icon:
        Icons
            .settings_outlined,
        color:
        Color(0xFF00A67E),
      );
    }

    if (type.contains('payment')) {
      return const _NotificationVisualData(
        icon:
        Icons
            .payments_outlined,
        color:
        Color(0xFF18A675),
      );
    }

    return const _NotificationVisualData(
      icon:
      Icons.notifications_none_rounded,
      color: orange,
    );
  }
}

class _NotificationsHeader
    extends StatelessWidget {
  final double topInset;
  final int unreadCount;
  final bool isMarkingAll;

  final VoidCallback onBack;
  final VoidCallback onMarkAll;

  const _NotificationsHeader({
    required this.topInset,
    required this.unreadCount,
    required this.isMarkingAll,
    required this.onBack,
    required this.onMarkAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        14,
        topInset + 10,
        14,
        22,
      ),
      decoration:
      const BoxDecoration(
        gradient: LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            Color(0xFF172033),
            Color(0xFF202B3D),
          ],
        ),
        borderRadius:
        BorderRadius.vertical(
          bottom:
          Radius.circular(27),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderButton(
                icon:
                Icons.arrow_back_rounded,
                onTap: onBack,
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Notifications',
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              if (unreadCount > 0)
                TextButton(
                  onPressed:
                  isMarkingAll
                      ? null
                      : onMarkAll,
                  style:
                  TextButton.styleFrom(
                    foregroundColor:
                    _NotificationsViewState
                        .orange,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 9,
                    ),
                  ),
                  child:
                  isMarkingAll
                      ? const SizedBox(
                    width: 15,
                    height: 15,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color:
                      _NotificationsViewState
                          .orange,
                    ),
                  )
                      : const Text(
                    'Read all',
                    style:
                    TextStyle(
                      fontSize:
                      11,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                BoxDecoration(
                  color: Colors.white
                      .withOpacity(.09),
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                child: const Icon(
                  Icons
                      .notifications_active_outlined,
                  color:
                  _NotificationsViewState
                      .orange,
                  size: 20,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      unreadCount == 0
                          ? 'You are all caught up'
                          : '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      'Orders, requests, services and account updates',
                      style:
                      TextStyle(
                        color: Colors.white
                            .withOpacity(.52),
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
      Colors.white.withOpacity(.09),
      borderRadius:
      BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(13),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard
    extends StatelessWidget {
  final CustomerNotificationModel
  notification;

  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread =
    !notification.isRead;

    final visual =
    _NotificationsViewState
        ._notificationVisual(
      notification,
    );

    return Material(
      color: unread
          ? const Color(0xFFFFFAF4)
          : Colors.white,
      borderRadius:
      BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Container(
          padding:
          const EdgeInsets.fromLTRB(
            12,
            12,
            11,
            12,
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: unread
                  ? const Color(
                0xFFF4D5B8,
              )
                  : const Color(
                0xFFE7E9ED,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _NotificationIcon(
                icon: visual.icon,
                color: visual.color,
                size: 42,
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification
                                .title,
                            maxLines: 2,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            TextStyle(
                              color:
                              _NotificationsViewState
                                  .ink,
                              fontSize:
                              12.5,
                              height: 1.25,
                              fontWeight:
                              unread
                                  ? FontWeight
                                  .w700
                                  : FontWeight
                                  .w600,
                            ),
                          ),
                        ),

                        if (unread) ...[
                          const SizedBox(
                            width: 7,
                          ),
                          Container(
                            width: 7,
                            height: 7,
                            margin:
                            const EdgeInsets.only(
                              top: 4,
                            ),
                            decoration:
                            const BoxDecoration(
                              color:
                              _NotificationsViewState
                                  .orange,
                              shape:
                              BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (notification
                        .body.isNotEmpty) ...[
                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF777F8C,
                          ),
                          fontSize:
                          10.5,
                          height: 1.35,
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 7,
                    ),

                    Row(
                      children: [
                        Text(
                          _NotificationsViewState
                              ._formatTime(
                            notification
                                .createdAt,
                          ),
                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFFA0A6AF,
                            ),
                            fontSize: 9,
                          ),
                        ),

                        const Spacer(),

                        const Icon(
                          Icons
                              .arrow_forward_ios_rounded,
                          size: 10,
                          color:
                          Color(
                            0xFFB0B5BD,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon
    extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _NotificationIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
        color.withOpacity(.10),
        borderRadius:
        BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}

class _NotificationVisualData {
  final IconData icon;
  final Color color;

  const _NotificationVisualData({
    required this.icon,
    required this.color,
  });
}

class _LoadingView
    extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:
      const EdgeInsets.fromLTRB(
        14,
        18,
        14,
        30,
      ),
      itemCount: 6,
      separatorBuilder:
          (_, __) =>
      const SizedBox(
        height: 9,
      ),
      itemBuilder: (_, __) {
        return Container(
          height: 92,
          decoration:
          BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color:
              const Color(
                0xFFE9EBEF,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState
    extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 34,
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
              BoxDecoration(
                color:
                _NotificationsViewState
                    .orange
                    .withOpacity(.08),
                shape:
                BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .notifications_none_rounded,
                color:
                _NotificationsViewState
                    .orange,
                size: 30,
              ),
            ),

            const SizedBox(
              height: 17,
            ),

            const Text(
              'Nothing new yet',
              style:
              TextStyle(
                color:
                _NotificationsViewState
                    .ink,
                fontSize: 15,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Important updates about your orders, requests and services will appear here.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color:
                Color(
                  0xFF8B929D,
                ),
                fontSize: 10.5,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(28),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration:
              BoxDecoration(
                color:
                _NotificationsViewState
                    .orange
                    .withOpacity(.08),
                shape:
                BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .wifi_off_rounded,
                color:
                _NotificationsViewState
                    .orange,
                size: 26,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(
              'Could not load notifications',
              style:
              TextStyle(
                color:
                _NotificationsViewState
                    .ink,
                fontSize: 14,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              message,
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                color:
                Color(
                  0xFF8B929D,
                ),
                fontSize: 10.5,
                height: 1.4,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            SizedBox(
              height: 42,
              child:
              FilledButton.icon(
                onPressed:
                onRetry,
                icon:
                const Icon(
                  Icons
                      .refresh_rounded,
                  size: 17,
                ),
                label:
                const Text(
                  'Try again',
                ),
                style:
                FilledButton.styleFrom(
                  backgroundColor:
                  _NotificationsViewState
                      .ink,
                  foregroundColor:
                  Colors.white,
                  textStyle:
                  const TextStyle(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}