import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/features/marketplace/data/models/marketplace_filter_model.dart';
import 'package:talabatfresh/features/marketplace/page/cart_page.dart';
import 'package:talabatfresh/features/marketplace/page/product_details_page.dart';
import 'package:talabatfresh/features/marketplace/page/widgets/marketplace_filter_sheet.dart';

import '../data/models/product_category_model.dart';
import '../data/models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/marketplace_provider.dart';

class PartsPage extends StatefulWidget {
  const PartsPage({super.key});

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);

  @override
  State<PartsPage> createState() => _PartsPageState();
}

class _PartsPageState extends State<PartsPage>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    Future.microtask(() async {
      final provider = context.read<MarketplaceProvider>();
      await provider.loadInitial();
      await provider.selectProductType('part');

      if (mounted) {
        context.read<CartProvider>().loadCart();
      }
    });

    tabController.addListener(() {
      if (!tabController.indexIsChanging) return;

      final type = tabController.index == 0 ? 'part' : 'tire';

      searchController.clear();

      final provider = context.read<MarketplaceProvider>();
      provider.clearFilters();
      provider.selectProductType(type);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String value) async {
    await context.read<MarketplaceProvider>().search(value);
  }

  Future<void> _refresh() async {
    final type = tabController.index == 0 ? 'part' : 'tire';
    await context.read<MarketplaceProvider>().selectProductType(type);
    await context.read<CartProvider>().loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final marketplace = context.watch<MarketplaceProvider>();
    final cart = context.watch<CartProvider>();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : PartsPage.darkGrey;
    final subtleTextColor =
    isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Container(
          color: const Color(0xFFF3F4F6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(
                textColor: textColor,
                cartCount: cart.itemsCount,
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: tabController,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: PartsPage.primaryOrange,
                      width: 3,
                    ),
                    insets: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  labelColor: textColor,
                  unselectedLabelColor: subtleTextColor,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: 'Parts'),
                    Tab(text: 'Tires'),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    _MarketplaceTabContent(
                      isDark: isDark,
                      textColor: textColor,
                      subtleTextColor: subtleTextColor,
                      isTiresTab: false,
                      searchController: searchController,
                      marketplace: marketplace,
                      onSearch: _onSearch,
                      onRefresh: _refresh,
                    ),
                    _MarketplaceTabContent(
                      isDark: isDark,
                      textColor: textColor,
                      subtleTextColor: subtleTextColor,
                      isTiresTab: true,
                      searchController: searchController,
                      marketplace: marketplace,
                      onSearch: _onSearch,
                      onRefresh: _refresh,
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

class _TopBar extends StatelessWidget {
  final Color textColor;
  final int cartCount;

  const _TopBar({
    required this.textColor,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Parts marketplace',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
    InkWell(
    borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CartPage(),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.10)
                        : Colors.grey.shade300,
                  ),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 21,
                  color: PartsPage.primaryOrange,
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      cartCount > 99 ? '99+' : cartCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          ),
        ],
      ),
    );
  }
}

class _MarketplaceTabContent extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color subtleTextColor;
  final bool isTiresTab;
  final TextEditingController searchController;
  final MarketplaceProvider marketplace;
  final Future<void> Function(String value) onSearch;
  final Future<void> Function() onRefresh;

  const _MarketplaceTabContent({
    required this.isDark,
    required this.textColor,
    required this.subtleTextColor,
    required this.isTiresTab,
    required this.searchController,
    required this.marketplace,
    required this.onSearch,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sectionTitle =
    isTiresTab ? 'Top tire picks for your car' : 'Top picks for your car';

    final searchHint =
    isTiresTab ? 'Search by tire size or brand' : 'Search by part, number or VIN';

    final categories = marketplace.categories.where((category) {
      if (isTiresTab) {
        return category.categoryType == 'tires';
      }

      return category.categoryType == 'parts' ||
          category.categoryType == 'accessories' ||
          category.categoryType == null;
    }).toList();

    final products = marketplace.products;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchAndFilter(
            controller: searchController,
            hint: searchHint,
            isDark: isDark,
            onSubmitted: onSearch,
            onFilterTap: () async {
              final provider = marketplace;

              if (provider.filterOptions == null) {
                await provider.loadFilterOptions(
                  productType: isTiresTab ? 'tire' : 'part',
                );
              }

              if (context.mounted && provider.filterOptions != null) {
                final result = await showModalBottomSheet<MarketplaceFilterState>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) {
                    return MarketplaceFilterSheet(
                      options: provider.filterOptions!,
                      currentFilter: provider.filter,
                      productType: isTiresTab ? 'tire' : 'part',
                    );
                  },
                );

                if (result != null) {
                  await provider.applyFilters(result);
                }
              }
            },
          ),

          const SizedBox(height: 12),

          _CategoriesRow(
            categories: categories,
            selectedCategoryId: marketplace.selectedCategoryId,
            isDark: isDark,
            onTap: (id) {
              marketplace.selectCategory(id);
            },
          ),

          const SizedBox(height: 16),

          Expanded(
            child: marketplace.isLoading && marketplace.products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : marketplace.errorMessage != null && marketplace.products.isEmpty
                ? _ErrorView(
              message: marketplace.errorMessage!,
              onRetry: onRefresh,
            )
                : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: sectionTitle,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 10),

                  if (products.isEmpty)
                    _EmptyProductsCard(
                      isDark: isDark,
                      text: isTiresTab
                          ? 'No tires available yet'
                          : 'No parts available yet',
                    )
                  else
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: products.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.60,
                      ),
                      itemBuilder: (ctx, index) {
                        return _ProductCard(
                          product: products[index],
                          isDark: isDark,
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  Text(
                    'Popular brands',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _BrandsWrap(
                    products: products,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final Future<void> Function(String value) onSubmitted;
  final VoidCallback onFilterTap;

  const _SearchAndFilter({
    required this.controller,
    required this.hint,
    required this.isDark,
    required this.onSubmitted,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    controller.clear();
                    onSubmitted('');
                  },
                )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF020617) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: PartsPage.primaryOrange,
                    width: 1.4,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isDark ? const Color(0xFF020617) : Colors.white,
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey.shade300,
              ),
            ),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(14),
              child: const Center(
                child: Icon(Icons.tune_rounded, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  final List<ProductCategoryModel> categories;
  final int? selectedCategoryId;
  final bool isDark;
  final void Function(int? id) onTap;

  const _CategoriesRow({
    required this.categories,
    required this.selectedCategoryId,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final list = [
      const ProductCategoryModel(id: null, name: 'All'),
      ...categories,
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, index) {
          final category = list[index];

          return _CategoryChip(
            label: category.name,
            icon: _categoryIcon(category.categoryType),
            selected: selectedCategoryId == category.id ||
                (selectedCategoryId == null && category.id == null),
            onTap: () => onTap(category.id),
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String? type) {
    switch (type) {
      case 'tires':
        return Icons.blur_circular_rounded;
      case 'accessories':
        return Icons.widgets_rounded;
      default:
        return Icons.build_rounded;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = selected
        ? PartsPage.primaryOrange.withOpacity(0.16)
        : isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFF3F4F6);

    final textColor = selected
        ? PartsPage.primaryOrange
        : isDark
        ? Colors.white
        : const Color(0xFF374151);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: bg,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionHeader({
    required this.title,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        Text(
          'View all',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: PartsPage.primaryOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isDark;

  const _ProductCard({
    required this.product,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseBg = isDark ? const Color(0xFF020617) : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (product.id == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(
              productId: product.id!,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: baseBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(
              imageUrl: product.imageUrl,
              isTire: product.isTire,
              isDark: isDark,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TagChip(
                    text: product.isInStock ? 'In stock' : 'Out of stock',
                    color: product.isInStock
                        ? PartsPage.primaryOrange
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand ?? 'Unknown brand',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.isTire
                        ? product.tireSpec?.displaySize ?? 'Tire'
                        : product.shortDescription ?? 'Car part',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_rounded,
                        size: 14,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${product.stockQty} available',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: PartsPage.primaryOrange.withOpacity(0.10),
                        ),
                        child: Text(
                          'View',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: PartsPage.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final bool isTire;
  final bool isDark;

  const _ProductImage({
    required this.imageUrl,
    required this.isTire,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            const Color(0xFF0B1120),
            const Color(0xFF111827),
          ]
              : [
            const Color(0xFFFFE0B2),
            const Color(0xFFFFF3E0),
          ],
        ),
      ),
      child: imageUrl.isNotEmpty
          ? ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _FallbackIcon(isTire: isTire),
        ),
      )
          : _FallbackIcon(isTire: isTire),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final bool isTire;

  const _FallbackIcon({
    required this.isTire,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        isTire ? Icons.blur_circular_rounded : Icons.build_rounded,
        size: 30,
        color: PartsPage.primaryOrange,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  final Color color;

  const _TagChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withOpacity(0.10),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BrandsWrap extends StatelessWidget {
  final List<ProductModel> products;
  final bool isDark;

  const _BrandsWrap({
    required this.products,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final brands = products
        .map((e) => e.brand)
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toSet()
        .take(10)
        .toList();

    if (brands.isEmpty) {
      return Text(
        'No brands yet',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: brands.map((brand) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFFF3F4F6),
          ),
          child: Text(
            brand,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isDark ? Colors.white : const Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyProductsCard extends StatelessWidget {
  final bool isDark;
  final String text;

  const _EmptyProductsCard({
    required this.isDark,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 46,
            color: PartsPage.primaryOrange,
          ),
          const SizedBox(height: 10),
          Text(text),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
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
    );
  }
}