import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/marketplace_provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color lightBackground = Color(0xFFF3F4F6);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int qty = 1;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<MarketplaceProvider>().loadProductDetails(widget.productId);
    });
  }

  Future<void> _addToCart(ProductModel product) async {
    if (product.id == null) return;

    final cartProvider = context.read<CartProvider>();

    final success = await cartProvider.addItem(
      productId: product.id!,
      qty: qty,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Product added to cart'
              : cartProvider.errorMessage ?? 'Failed to add product',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketplaceProvider>();
    final cartProvider = context.watch<CartProvider>();

    final product = provider.selectedProduct;

    return Scaffold(
      backgroundColor: ProductDetailsPage.lightBackground,
      appBar: AppBar(
        title: const Text('Product details'),
        backgroundColor: ProductDetailsPage.lightBackground,
        elevation: 0,
      ),
      bottomNavigationBar: product == null
          ? null
          : SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          child: Row(
            children: [
              _QtySelector(
                qty: qty,
                onMinus: qty > 1
                    ? () {
                  setState(() => qty--);
                }
                    : null,
                onPlus: qty < product.stockQty
                    ? () {
                  setState(() => qty++);
                }
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: product.isInStock && !cartProvider.isSubmitting
                        ? () => _addToCart(product)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProductDetailsPage.primaryOrange,
                      foregroundColor: Colors.white,
                    ),
                    icon: cartProvider.isSubmitting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.shopping_cart_outlined),
                    label: Text(
                      product.isInStock ? 'Add to cart' : 'Out of stock',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: provider.isLoadingDetails
          ? const Center(child: CircularProgressIndicator())
          : product == null
          ? _ErrorView(
        message: provider.errorMessage ?? 'Product not found',
        onRetry: () {
          provider.loadProductDetails(widget.productId);
        },
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImageGallery(product: product),
            const SizedBox(height: 16),

            _ProductMainInfo(product: product),
            const SizedBox(height: 16),

            if (product.isTire && product.tireSpec != null) ...[
              _TireSpecCard(spec: product.tireSpec!),
              const SizedBox(height: 16),
            ],

            if (product.description != null &&
                product.description!.isNotEmpty) ...[
              _SectionCard(
                title: 'Description',
                child: Text(product.description!),
              ),
              const SizedBox(height: 16),
            ],

            if (product.fitments.isNotEmpty) ...[
              _FitmentsCard(fitments: product.fitments),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductImageGallery extends StatelessWidget {
  final ProductModel product;

  const _ProductImageGallery({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final images = product.images.isNotEmpty
        ? product.images
        : [
      if (product.primaryImage != null) product.primaryImage!,
    ];

    if (images.isEmpty) {
      return Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFE0B2),
              Color(0xFFFFF3E0),
            ],
          ),
        ),
        child: Icon(
          product.isTire ? Icons.blur_circular_rounded : Icons.build_rounded,
          size: 72,
          color: ProductDetailsPage.primaryOrange,
        ),
      );
    }

    return SizedBox(
      height: 230,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (_, index) {
          final imageUrl = images[index].imageUrl ?? '';

          return ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFFFF3E0),
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 64,
                  color: ProductDetailsPage.primaryOrange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductMainInfo extends StatelessWidget {
  final ProductModel product;

  const _ProductMainInfo({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: product.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((product.brand ?? '').isNotEmpty)
            Text(
              product.brand!,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              _StatusChip(
                text: product.isInStock ? 'In stock' : 'Out of stock',
                color: product.isInStock
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            product.shortDescription ??
                (product.isTire ? 'Tire product' : 'Car part'),
            style: const TextStyle(
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Available quantity: ${product.stockQty}',
            style: const TextStyle(
              color: Color(0xFF059669),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TireSpecCard extends StatelessWidget {
  final TireSpecModel spec;

  const _TireSpecCard({
    required this.spec,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Tire specifications',
      child: Column(
        children: [
          _SpecRow(label: 'Size', value: spec.displaySize),
          _SpecRow(label: 'Season', value: spec.season ?? '-'),
          _SpecRow(label: 'Load index', value: spec.loadIndex ?? '-'),
          _SpecRow(label: 'Speed rating', value: spec.speedRating ?? '-'),
          _SpecRow(label: 'Run flat', value: spec.runFlat ? 'Yes' : 'No'),
          _SpecRow(label: 'Tread type', value: spec.treadType ?? '-'),
        ],
      ),
    );
  }
}

class _FitmentsCard extends StatelessWidget {
  final List<ProductFitmentModel> fitments;

  const _FitmentsCard({
    required this.fitments,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Vehicle fitment',
      child: Column(
        children: fitments.map((fitment) {
          final years = [
            if (fitment.yearFrom != null) fitment.yearFrom.toString(),
            if (fitment.yearTo != null) fitment.yearTo.toString(),
          ].join(' - ');

          final name = [
            if (years.isNotEmpty) years,
            if (fitment.makeName != null) fitment.makeName,
            if (fitment.modelName != null) fitment.modelName,
            if (fitment.trimName != null) fitment.trimName,
          ].whereType<String>().where((e) => e.isNotEmpty).join(' ');

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: ProductDetailsPage.primaryOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(name.isEmpty ? 'Compatible vehicle' : name),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _QtySelector extends StatelessWidget {
  final int qty;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const _QtySelector({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove),
          ),
          Text(
            qty.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}