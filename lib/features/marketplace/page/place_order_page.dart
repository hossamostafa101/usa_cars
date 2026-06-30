import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile/data/models/address_model.dart';
import '../providers/cart_provider.dart';
import '../providers/place_order_provider.dart';

class PlaceOrderPage extends StatefulWidget {
  const PlaceOrderPage({super.key});

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color lightBackground = Color(0xFFF3F4F6);

  @override
  State<PlaceOrderPage> createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  final notesController = TextEditingController();

  static const double shippingAmount = 10.00;
  static const double taxRate = 0.08;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      context.read<CartProvider>().loadCart();
      context.read<PlaceOrderProvider>().loadCheckoutData();
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cartProvider = context.read<CartProvider>();
    final placeOrderProvider = context.read<PlaceOrderProvider>();

    final subtotal = cartProvider.subtotal;
    final taxAmount = subtotal * taxRate;

    final success = await placeOrderProvider.placeOrderAndSimulatePayment(
      shippingAmount: shippingAmount,
      taxAmount: taxAmount,
      notes: notesController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            placeOrderProvider.errorMessage ?? 'Failed to place order.',
          ),
        ),
      );
      return;
    }

    await cartProvider.loadCart();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OrderSuccessPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final checkout = context.watch<PlaceOrderProvider>();

    final cart = cartProvider.cart;
    final items = cart?.items ?? [];

    final subtotal = cartProvider.subtotal;
    final taxAmount = subtotal * taxRate;
    final total = subtotal + taxAmount + shippingAmount;

    return Scaffold(
      backgroundColor: PlaceOrderPage.lightBackground,
      appBar: AppBar(
        title: const Text('Place Order'),
        backgroundColor: PlaceOrderPage.lightBackground,
        elevation: 0,
      ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
        child: _CheckoutBottomBar(
          total: total,
          isLoading: checkout.isPlacingOrder,
          onPlaceOrder: _placeOrder,
        ),
      ),
      body: checkout.isLoading || (cartProvider.isLoading && cart == null)
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const _EmptyCheckout()
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: 'Shipping address',
              actionText: checkout.addresses.isEmpty ? null : 'Change',
              onTap: () => _openAddressSelector(
                isShipping: true,
              ),
            ),
            const SizedBox(height: 10),
            checkout.selectedShippingAddress == null
                ? const _MissingAddressCard()
                : _AddressCard(
              address: checkout.selectedShippingAddress!,
            ),

            const SizedBox(height: 22),

            _SectionTitle(
              title: 'Order items',
              actionText: '${items.length} items',
            ),
            const SizedBox(height: 10),

            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = items[index];

                return _OrderItemTile(
                  title: item.product?.name ?? 'Product',
                  subtitle: item.product?.brand ?? '',
                  qty: item.qty,
                  price: item.unitPrice,
                );
              },
            ),

            const SizedBox(height: 22),

            _SectionTitle(title: 'Notes'),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Optional notes for this order',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 22),

            _SectionTitle(title: 'Payment'),
            const SizedBox(height: 10),
            const _PaymentSimulationCard(),

            const SizedBox(height: 22),

            _SectionTitle(title: 'Summary'),
            const SizedBox(height: 10),
            _SummaryCard(
              subtotal: subtotal,
              shipping: shippingAmount,
              tax: taxAmount,
              total: total,
            ),
          ],
        ),
      ),
    );
  }

  void _openAddressSelector({
    required bool isShipping,
  }) {
    final provider = context.read<PlaceOrderProvider>();

    if (provider.addresses.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return _AddressSelectorSheet(
          title: isShipping ? 'Select shipping address' : 'Select billing address',
          addresses: provider.addresses,
          selectedAddress: isShipping
              ? provider.selectedShippingAddress
              : provider.selectedBillingAddress,
          onSelected: (address) {
            if (isShipping) {
              provider.selectShippingAddress(address);
            } else {
              provider.selectBillingAddress(address);
            }

            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const _SectionTitle({
    required this.title,
    this.actionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ),
        if (actionText != null)
          InkWell(
            onTap: onTap,
            child: Text(
              actionText!,
              style: const TextStyle(
                color: PlaceOrderPage.primaryOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;

  const _AddressCard({
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: PlaceOrderPage.primaryOrange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address.fullAddress,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
                if ((address.phone ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    address.phone!,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
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

class _MissingAddressCard extends StatelessWidget {
  const _MissingAddressCard();

  @override
  Widget build(BuildContext context) {
    return const _WhiteCard(
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF59E0B),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No address found. Please add an address before checkout.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int qty;
  final double price;

  const _OrderItemTile({
    required this.title,
    required this.subtitle,
    required this.qty,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: PlaceOrderPage.primaryOrange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'x$qty',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '\$${(price * qty).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSimulationCard extends StatelessWidget {
  const _PaymentSimulationCard();

  @override
  Widget build(BuildContext context) {
    return const _WhiteCard(
      child: Row(
        children: [
          Icon(
            Icons.payments_rounded,
            color: PlaceOrderPage.primaryOrange,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Payment will be simulated for now. The order will be marked as paid automatically.',
              style: TextStyle(
                color: Color(0xFF374151),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;

  const _SummaryCard({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: subtotal),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Shipping', value: shipping),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Tax', value: tax),
          const Divider(height: 24),
          _SummaryRow(
            label: 'Total',
            value: total,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? const Color(0xFF111827) : const Color(0xFF6B7280),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 17 : 14,
          ),
        ),
        const Spacer(),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
            color: isTotal
                ? PlaceOrderPage.primaryOrange
                : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final double total;
  final bool isLoading;
  final VoidCallback onPlaceOrder;

  const _CheckoutBottomBar({
    required this.total,
    required this.isLoading,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: PlaceOrderPage.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onPlaceOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: PlaceOrderPage.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressSelectorSheet extends StatelessWidget {
  final String title;
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;
  final void Function(AddressModel address) onSelected;

  const _AddressSelectorSheet({
    required this.title,
    required this.addresses,
    required this.selectedAddress,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ...addresses.map((address) {
              final selected = selectedAddress?.id == address.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => onSelected(address),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? PlaceOrderPage.primaryOrange
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? PlaceOrderPage.primaryOrange
                              : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            address.fullAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _EmptyCheckout extends StatelessWidget {
  const _EmptyCheckout();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Cart is empty.'),
    );
  }
}

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaceOrderProvider>();
    final order = provider.order;
    final payment = provider.payment;

    return Scaffold(
      backgroundColor: PlaceOrderPage.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PlaceOrderPage.primaryOrange.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 54,
                  color: PlaceOrderPage.primaryOrange,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Order placed successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                order?.orderNumber == null
                    ? 'Your order has been created and payment was simulated.'
                    : 'Order ${order!.orderNumber} has been created and payment was simulated.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment status: ${payment?.status ?? order?.paymentStatus ?? 'paid'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PlaceOrderPage.primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Back to home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}