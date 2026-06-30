import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/features/marketplace/page/place_order_page.dart';

import '../data/models/cart_model.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color lightBackground = Color(0xFFF3F4F6);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CartProvider>().loadCart();
    });
  }

  Future<void> _removeItem(int itemId) async {
    final provider = context.read<CartProvider>();

    final success = await provider.removeItem(itemId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Item removed' : provider.errorMessage ?? 'Failed',
        ),
      ),
    );
  }

  Future<void> _clearCart() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Clear cart?'),
          content: const Text('Are you sure you want to remove all items?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final provider = context.read<CartProvider>();
    final success = await provider.clearCart();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Cart cleared' : provider.errorMessage ?? 'Failed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final cart = provider.cart;
    final items = cart?.items ?? [];

    return Scaffold(
      backgroundColor: CartPage.lightBackground,
      appBar: AppBar(
        backgroundColor: CartPage.lightBackground,
        elevation: 0,
        title: const Text('Cart'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: provider.isSubmitting ? null : _clearCart,
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
        child: _CartSummaryBar(
          subtotal: provider.subtotal,
          isLoading: provider.isSubmitting,
          onCheckout: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PlaceOrderPage(),
              ),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadCart,
        child: provider.isLoading && cart == null
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 120),
            Icon(
              Icons.shopping_cart_outlined,
              size: 86,
              color: CartPage.primaryOrange,
            ),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add parts or tires to your cart to continue checkout.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        )
            : ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final item = items[index];

            return _CartItemCard(
              item: item,
              isSubmitting: provider.isSubmitting,
              onMinus: item.qty > 1 && item.id != null
                  ? () {
                provider.updateItemQty(
                  itemId: item.id!,
                  qty: item.qty - 1,
                );
              }
                  : null,
              onPlus: item.id != null
                  ? () {
                provider.updateItemQty(
                  itemId: item.id!,
                  qty: item.qty + 1,
                );
              }
                  : null,
              onRemove: item.id == null
                  ? null
                  : () => _removeItem(item.id!),
            );
          },
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final bool isSubmitting;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final VoidCallback? onRemove;

  const _CartItemCard({
    required this.item,
    required this.isSubmitting,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductThumb(
            imageUrl: product?.imageUrl ?? '',
            isTire: product?.isTire ?? false,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? 'Product',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  product?.brand ?? '',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CartPage.primaryOrange,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: isSubmitting ? null : onMinus,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        item.qty.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: isSubmitting ? null : onPlus,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: isSubmitting ? null : onRemove,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final String imageUrl;
  final bool isTire;

  const _ProductThumb({
    required this.imageUrl,
    required this.isTire,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFFFF3E0),
      ),
      child: imageUrl.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Icon(
      isTire ? Icons.blur_circular_rounded : Icons.build_rounded,
      color: CartPage.primaryOrange,
      size: 34,
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  final double subtotal;
  final bool isLoading;
  final VoidCallback onCheckout;

  const _CartSummaryBar({
    required this.subtotal,
    required this.isLoading,
    required this.onCheckout,
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
                  'Subtotal',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: CartPage.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28),
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
                  : const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}