import 'package:flutter/material.dart';

import '../data/models/order_model.dart';
import '../data/services/order_api_service.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;
  final OrderModel? initialOrder;

  const OrderDetailsPage({super.key, required this.orderId, this.initialOrder});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  static const orange = Color(0xFFF57C00);

  final OrderApiService _api = OrderApiService();

  OrderModel? order;

  bool isLoading = true;
  bool isCancelling = false;

  String? error;

  @override
  void initState() {
    super.initState();

    order = widget.initialOrder;

    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final result = await _api.getOrderDetails(widget.orderId);

      if (!mounted) return;

      setState(() {
        order = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  bool get canCancel {
    final status = order?.orderStatus;

    return status == 'pending' || status == 'confirmed';
  }

  Future<void> _cancel() async {
    if (!canCancel || isCancelling) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Cancel order?'),
            content: const Text('Are you sure you want to cancel this order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep order'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Cancel order',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      setState(() {
        isCancelling = true;
      });

      final result = await _api.cancelOrder(widget.orderId);

      if (!mounted) return;

      setState(() {
        order = result;
        isCancelling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCancelling = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = order;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B0F16) : const Color(0xFFF5F6F8),
      appBar: AppBar(title: const Text('Order details')),
      body:
          isLoading && current == null
              ? const Center(child: CircularProgressIndicator(color: orange))
              : current == null
              ? Center(child: Text(error ?? 'Order not found.'))
              : RefreshIndicator(
                color: orange,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // _SummaryCard(order: current, isDark: isDark),

                    if (current.items.isNotEmpty) ...[
                      const SizedBox(height: 12),

                      _OrderItemsCard(
                        items: current.items,
                        isDark: isDark,
                      ),
                    ],

                    if (current.vendor != null) ...[
                      const SizedBox(height: 12),

                      _VendorCard(
                        vendor: current.vendor!,
                        isDark: isDark,
                      ),
                    ],

                    if (current.vehicle != null) ...[
                      const SizedBox(height: 12),

                      _VehicleCard(
                        vehicle: current.vehicle!,
                        isDark: isDark,
                      ),
                    ],

                    if ((current.notes ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 12),

                      _NotesCard(
                        notes: current.notes!,
                        isDark: isDark,
                      ),
                    ],

                    const SizedBox(height: 12),

                    _MoneyCard(
                      order: current,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),

                    _MoneyCard(order: current, isDark: isDark),

                    if (canCancel) ...[
                      const SizedBox(height: 18),

                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: isCancelling ? null : _cancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          icon:
                              isCancelling
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.cancel_outlined),
                          label: const Text('Cancel order'),
                        ),
                      ),
                    ],

                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final OrderModel order;
  final bool isDark;

  const _SummaryCard({required this.order, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151B25) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.orderNumber ?? 'Order #${order.id ?? ''}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 14),

          _InfoRow(label: 'Order status', value: order.orderStatus),

          const Divider(),

          _InfoRow(label: 'Payment status', value: order.paymentStatus),
        ],
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  final OrderModel order;
  final bool isDark;

  const _MoneyCard({required this.order, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151B25) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _MoneyRow(label: 'Subtotal', amount: order.subtotal),

          const SizedBox(height: 9),

          _MoneyRow(label: 'Tax', amount: order.taxAmount),

          const SizedBox(height: 9),

          _MoneyRow(label: 'Shipping', amount: order.shippingAmount),

          const Divider(height: 25),

          _MoneyRow(label: 'Total', amount: order.totalAmount, strong: true),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF8B929C))),
        ),
        Text(
          value.isEmpty ? '-' : value.replaceAll('_', ' '),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool strong;

  const _MoneyRow({
    required this.label,
    required this.amount,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: strong ? 16 : 13,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}





class _OrderItemsCard
    extends StatelessWidget {
  final List<OrderItemModel> items;
  final bool isDark;

  const _OrderItemsCard({
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      isDark: isDark,
      title: 'Items',
      child: Column(
        children: List.generate(
          items.length,
              (index) {
            final item = items[index];

            return Column(
              children: [
                if (index > 0)
                  const Divider(
                    height: 24,
                  ),

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration:
                      BoxDecoration(
                        color: const Color(
                          0xFFF57C00,
                        ).withOpacity(.10),
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .inventory_2_outlined,
                        color: Color(
                          0xFFF57C00,
                        ),
                        size: 21,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            item.productName
                                .trim()
                                .isEmpty
                                ? item.product
                                ?.name ??
                                'Product'
                                : item.productName,
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .w700,
                              fontSize: 12,
                            ),
                          ),

                          if ((item
                              .product
                              ?.brand ??
                              '')
                              .trim()
                              .isNotEmpty) ...[
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              item.product!
                                  .brand!,
                              style:
                              const TextStyle(
                                color: Color(
                                  0xFF8B929C,
                                ),
                                fontSize: 9,
                              ),
                            ),
                          ],

                          if ((item.sku ?? '')
                              .trim()
                              .isNotEmpty) ...[
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              'SKU ${item.sku}',
                              style:
                              const TextStyle(
                                color: Color(
                                  0xFF8B929C,
                                ),
                                fontSize: 8.5,
                              ),
                            ),
                          ],

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            '${item.qty} × \$${item.unitPrice.toStringAsFixed(2)}',
                            style:
                            const TextStyle(
                              color: Color(
                                0xFF6B7280,
                              ),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VendorCard
    extends StatelessWidget {
  final OrderVendorModel vendor;
  final bool isDark;

  const _VendorCard({
    required this.vendor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      isDark: isDark,
      title: 'Seller',
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
            BoxDecoration(
              color: const Color(
                0xFF6366F1,
              ).withOpacity(.10),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color:
              Color(0xFF6366F1),
              size: 21,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vendor.businessName ??
                            'Seller',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    if (vendor.isVerified) ...[
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons
                            .verified_rounded,
                        size: 15,
                        color: Color(
                          0xFF0EA5E9,
                        ),
                      ),
                    ],
                  ],
                ),

                if ((vendor
                    .businessType ??
                    '')
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    vendor.businessType!
                        .replaceAll(
                      '_',
                      ' ',
                    ),
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF8B929C,
                      ),
                      fontSize: 9,
                    ),
                  ),
                ],

                if ((vendor
                    .supportPhone ??
                    '')
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    vendor.supportPhone!,
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF8B929C,
                      ),
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard
    extends StatelessWidget {
  final OrderVehicleModel vehicle;
  final bool isDark;

  const _VehicleCard({
    required this.vehicle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (vehicle.year != null)
        vehicle.year.toString(),
      if ((vehicle.engine ?? '')
          .trim()
          .isNotEmpty)
        vehicle.engine!,
      if ((vehicle.fuelType ?? '')
          .trim()
          .isNotEmpty)
        vehicle.fuelType!,
    ];

    return _DetailsCard(
      isDark: isDark,
      title: 'Vehicle',
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
            BoxDecoration(
              color: const Color(
                0xFF10B981,
              ).withOpacity(.10),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: const Icon(
              Icons
                  .directions_car_outlined,
              color:
              Color(0xFF10B981),
              size: 22,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.vin ??
                      'Vehicle #${vehicle.id ?? ''}',
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 11,
                  ),
                ),

                if (details.isNotEmpty) ...[
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    details.join(' • '),
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF8B929C,
                      ),
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard
    extends StatelessWidget {
  final String notes;
  final bool isDark;

  const _NotesCard({
    required this.notes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      isDark: isDark,
      title: 'Order notes',
      child: Text(
        notes,
        style: const TextStyle(
          color: Color(
            0xFF7B8490,
          ),
          fontSize: 10,
          height: 1.45,
        ),
      ),
    );
  }
}

class _DetailsCard
    extends StatelessWidget {
  final bool isDark;
  final String title;
  final Widget child;

  const _DetailsCard({
    required this.isDark,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        16,
      ),
      decoration:
      BoxDecoration(
        color: isDark
            ? const Color(
          0xFF151B25,
        )
            : Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white
              .withOpacity(.06)
              : const Color(
            0xFFE5E7EB,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
            const TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          child,
        ],
      ),
    );
  }
}