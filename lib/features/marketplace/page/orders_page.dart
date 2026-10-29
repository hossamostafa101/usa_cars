import 'package:flutter/material.dart';

import '../data/models/order_model.dart';
import '../data/services/order_api_service.dart';
import 'order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({
    super.key,
  });

  static const Color orange =
  Color(0xFFF57C00);

  @override
  State<OrdersPage> createState() =>
      _OrdersPageState();
}

class _OrdersPageState
    extends State<OrdersPage> {
  final OrderApiService _api =
  OrderApiService();

  List<OrderModel> _orders = [];

  bool _isLoading = true;

  String? _error;

  String _status = 'all';

  static const statuses = [
    'all',
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'returned',
  ];

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final orders =
      await _api.getOrders(
        orderStatus:
        _status == 'all'
            ? null
            : _status,
      );

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _changeStatus(
      String status,
      ) async {
    if (_status == status) return;

    setState(() {
      _status = status;
    });

    await _load();
  }

  Future<void> _openOrder(
      OrderModel order,
      ) async {
    final id = order.id;

    if (id == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            OrderDetailsPage(
              orderId: id,
              initialOrder: order,
            ),
      ),
    );

    if (!mounted) return;

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0F16)
          : const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          'My orders',
        ),
        backgroundColor:
        Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: OrdersPage.orange,
        onRefresh: _load,
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection:
                Axis.horizontal,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                itemCount:
                statuses.length,
                separatorBuilder:
                    (_, __) =>
                const SizedBox(
                  width: 7,
                ),
                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final status =
                  statuses[index];

                  final selected =
                      status == _status;

                  return ChoiceChip(
                    selected:
                    selected,
                    label:
                    Text(
                      _statusLabel(
                        status,
                      ),
                    ),
                    selectedColor:
                    OrdersPage.orange,
                    labelStyle:
                    TextStyle(
                      color: selected
                          ? Colors.white
                          : null,
                      fontWeight:
                      selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    onSelected:
                        (_) {
                      _changeStatus(
                        status,
                      );
                    },
                  );
                },
              ),
            ),

            Expanded(
              child: _buildContent(
                isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      bool isDark,
      ) {
    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(
          color:
          OrdersPage.orange,
        ),
      );
    }

    if (_error != null &&
        _orders.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.all(
          24,
        ),
        children: [
          const SizedBox(
            height: 100,
          ),

          const Icon(
            Icons.error_outline,
            size: 48,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            _error!,
            textAlign:
            TextAlign.center,
          ),

          const SizedBox(
            height: 16,
          ),

          FilledButton(
            onPressed:
            _load,
            child:
            const Text(
              'Retry',
            ),
          ),
        ],
      );
    }

    if (_orders.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.all(
          24,
        ),
        children: const [
          SizedBox(
            height: 100,
          ),

          Icon(
            Icons
                .shopping_bag_outlined,
            size: 58,
            color:
            Color(
              0xFF9CA3AF,
            ),
          ),

          SizedBox(
            height: 14,
          ),

          Text(
            'No orders found',
            textAlign:
            TextAlign.center,
            style:
            TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Text(
            'Your marketplace orders will appear here.',
            textAlign:
            TextAlign.center,
            style:
            TextStyle(
              color:
              Color(
                0xFF7C8490,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        28,
      ),
      itemCount:
      _orders.length,
      separatorBuilder:
          (_, __) =>
      const SizedBox(
        height: 10,
      ),
      itemBuilder:
          (
          context,
          index,
          ) {
        final order =
        _orders[index];

        return _OrderCard(
          order: order,
          isDark:
          isDark,
          onTap:
              () => _openOrder(
            order,
          ),
        );
      },
    );
  }

  static String _statusLabel(
      String status,
      ) {
    switch (status) {
      case 'all':
        return 'All';

      case 'pending':
        return 'Pending';

      case 'confirmed':
        return 'Confirmed';

      case 'processing':
        return 'Processing';

      case 'shipped':
        return 'Shipped';

      case 'delivered':
        return 'Delivered';

      case 'cancelled':
        return 'Cancelled';

      case 'returned':
        return 'Returned';

      default:
        return status;
    }
  }
}

class _OrderCard
    extends StatelessWidget {
  final OrderModel order;
  final bool isDark;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
    _statusColor(
      order.orderStatus,
    );

    return Material(
      color: isDark
          ? const Color(0xFF151B25)
          : Colors.white,
      borderRadius:
      BorderRadius.circular(
        17,
      ),
      child: InkWell(
        onTap:
        onTap,
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        child: Container(
          padding:
          const EdgeInsets.all(
            14,
          ),
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              17,
            ),
            border:
            Border.all(
              color: isDark
                  ? Colors.white
                  .withOpacity(
                .06,
              )
                  : const Color(
                0xFFE5E7EB,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color: OrdersPage
                      .orange
                      .withOpacity(
                    .10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .shopping_bag_outlined,
                  color:
                  OrdersPage
                      .orange,
                  size:
                  21,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      order.orderNumber ??
                          'Order #${order.id ?? ''}',
                      style:
                      TextStyle(
                        color: isDark
                            ? Colors.white
                            : const Color(
                          0xFF172033,
                        ),
                        fontSize:
                        12,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      children: [
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal:
                            7,
                            vertical:
                            3,
                          ),
                          decoration:
                          BoxDecoration(
                            color: statusColor
                                .withOpacity(
                              .10,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              99,
                            ),
                          ),
                          child:
                          Text(
                            _statusLabel(
                              order
                                  .orderStatus,
                            ),
                            style:
                            TextStyle(
                              color:
                              statusColor,
                              fontSize:
                              8,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 7,
                        ),

                        Text(
                          _paymentLabel(
                            order.paymentStatus,
                          ),
                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFF8A919C,
                            ),
                            fontSize:
                            8.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style:
                    TextStyle(
                      color: isDark
                          ? Colors.white
                          : const Color(
                        0xFF172033,
                      ),
                      fontSize:
                      12,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  const Icon(
                    Icons
                        .chevron_right_rounded,
                    size:
                    18,
                    color:
                    Color(
                      0xFF9CA3AF,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _statusColor(
      String status,
      ) {
    switch (status) {
      case 'delivered':
        return const Color(
          0xFF10B981,
        );

      case 'cancelled':
      case 'returned':
        return const Color(
          0xFFEF4444,
        );

      case 'shipped':
        return const Color(
          0xFF0EA5E9,
        );

      case 'processing':
        return const Color(
          0xFF6366F1,
        );

      default:
        return OrdersPage.orange;
    }
  }

  static String _statusLabel(
      String status,
      ) {
    if (status.isEmpty) {
      return 'Unknown';
    }

    return status
        .replaceAll(
      '_',
      ' ',
    )
        .split(' ')
        .map(
          (e) => e.isEmpty
          ? e
          : '${e[0].toUpperCase()}${e.substring(1)}',
    )
        .join(' ');
  }

  static String _paymentLabel(
      String status,
      ) {
    if (status.isEmpty) {
      return '';
    }

    return status
        .replaceAll('_', ' ');
  }
}