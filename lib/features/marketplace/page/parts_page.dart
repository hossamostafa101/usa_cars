import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/features/marketplace/data/models/marketplace_filter_model.dart';
import 'package:talabatfresh/features/marketplace/page/cart_page.dart';
import 'package:talabatfresh/features/marketplace/page/product_details_page.dart';
import 'package:talabatfresh/features/marketplace/page/widgets/marketplace_filter_sheet.dart';

import '../../part_requests/pages/create_part_request_page.dart';
import '../../part_requests/pages/my_part_requests_page.dart';
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


  Timer? _searchDebounce;
  int _lastTabIndex = 0;


  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 2,
      vsync: this,
    );

    tabController.addListener(
      _handleTabChanged,
    );

    Future.microtask(() async {
      final marketplace =
      context.read<MarketplaceProvider>();

      // selectProductType already loads:
      // categories + filter options + products.
      await marketplace.selectProductType(
        'part',
      );

      if (!mounted) return;

      await context
          .read<CartProvider>()
          .loadCart();
    });
  }
  /*@override
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
  }*/

  @override
  void dispose() {
    _searchDebounce?.cancel();

    tabController.removeListener(
      _handleTabChanged,
    );

    tabController.dispose();
    searchController.dispose();

    super.dispose();
  }
  /*@override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }*/

  void _handleTabChanged() {
    final newIndex =
        tabController.index;

    if (newIndex == _lastTabIndex) {
      return;
    }

    _lastTabIndex = newIndex;

    _searchDebounce?.cancel();
    searchController.clear();

    final type =
    newIndex == 0
        ? 'part'
        : 'tire';

    context
        .read<MarketplaceProvider>()
        .selectProductType(type);
  }

  void _onSearchChanged(
      String value,
      ) {
    _searchDebounce?.cancel();

    if (value.trim().isEmpty) {
      context
          .read<MarketplaceProvider>()
          .search('');

      return;
    }

    _searchDebounce = Timer(
      const Duration(
        milliseconds: 450,
      ),
          () {
        if (!mounted) return;

        context
            .read<MarketplaceProvider>()
            .search(value);
      },
    );
  }

  Future<void> _onSearchSubmitted(
      String value,
      ) async {
    _searchDebounce?.cancel();

    await context
        .read<MarketplaceProvider>()
        .search(value);
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
    final marketplace =
    context.watch<MarketplaceProvider>();

    final cart =
    context.watch<CartProvider>();

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Container(
        color: isDark
            ? const Color(0xFF0B0F16)
            : const Color(0xFFF5F6F8),
        child: Column(
          children: [
            _MarketplaceHeader(
              cartCount:
              cart.itemsCount,
              isDark: isDark,
            ),

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                12,
              ),
              child: _MarketplaceTabs(
                controller:
                tabController,
                isDark:
                isDark,
              ),
            ),

            Expanded(
              child: TabBarView(
                controller:
                tabController,
                children: [
                  _MarketplaceTabContent(
                    isDark:
                    isDark,
                    isTiresTab:
                    false,
                    searchController:
                    searchController,
                    marketplace:
                    marketplace,
                    onSearchChanged:
                    _onSearchChanged,
                    onSearchSubmitted:
                    _onSearchSubmitted,
                    onRefresh:
                    _refresh,
                  ),

                  _MarketplaceTabContent(
                    isDark:
                    isDark,
                    isTiresTab:
                    true,
                    searchController:
                    searchController,
                    marketplace:
                    marketplace,
                    onSearchChanged:
                    _onSearchChanged,
                    onSearchSubmitted:
                    _onSearchSubmitted,
                    onRefresh:
                    _refresh,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  /*@override
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
  }*/
}

/*
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
          if (!isTiresTab) ...[
            const _PartRequestBanner(),
            const SizedBox(height: 12),
          ],
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
*/













class _PartRequestBanner
    extends StatelessWidget {
  const _PartRequestBanner();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF111827)
              : Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: PartsPage.primaryOrange
                .withOpacity(0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: PartsPage
                        .primaryOrange
                        .withOpacity(0.12),
                    borderRadius:
                    BorderRadius.circular(
                        12),
                  ),
                  child: const Icon(
                    Icons
                        .request_quote_outlined,
                    color: PartsPage
                        .primaryOrange,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        'Can’t find the exact part?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Request it and receive quotations from approved parts sellers.',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const CreatePartRequestPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_rounded,
                    ),
                    label: const Text(
                      'Request a Part',
                    ),
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      PartsPage
                          .primaryOrange,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child:
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const MyPartRequestsPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons
                          .receipt_long_outlined,
                    ),
                    label: const Text(
                      'My Requests',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}























class _MarketplaceHeader
    extends StatelessWidget {
  final int cartCount;
  final bool isDark;

  const _MarketplaceHeader({
    required this.cartCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        15,
        16,
        18,
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
          Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Marketplace',
                  style: TextStyle(
                    color:
                    Colors.white,
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Shop parts and tires',
                  style: TextStyle(
                    color:
                    Color(0xFFAAB2BE),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),

          Material(
            color: Colors.white
                .withOpacity(.09),
            borderRadius:
            BorderRadius.circular(
              13,
            ),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const CartPage(),
                  ),
                );

                if (!context.mounted) {
                  return;
                }

                context
                    .read<CartProvider>()
                    .loadCart();
              },
              borderRadius:
              BorderRadius.circular(
                13,
              ),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  clipBehavior:
                  Clip.none,
                  children: [
                    const Center(
                      child: Icon(
                        Icons
                            .shopping_cart_outlined,
                        color:
                        Colors.white,
                        size: 20,
                      ),
                    ),

                    if (cartCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child:
                        Container(
                          constraints:
                          const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          alignment:
                          Alignment.center,
                          decoration:
                          const BoxDecoration(
                            color:
                            PartsPage
                                .primaryOrange,
                            shape:
                            BoxShape.circle,
                          ),
                          child: Text(
                            cartCount > 99
                                ? '99+'
                                : '$cartCount',
                            style:
                            const TextStyle(
                              color:
                              Colors.white,
                              fontSize: 7,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}












class _MarketplaceTabs
    extends StatelessWidget {
  final TabController controller;
  final bool isDark;

  const _MarketplaceTabs({
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding:
      const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF151B25)
            : const Color(0xFFE9ECF0),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: controller,
        dividerColor:
        Colors.transparent,
        indicatorSize:
        TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: isDark
              ? const Color(0xFF252E3D)
              : Colors.white,
          borderRadius:
          BorderRadius.circular(
            11,
          ),
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black
                  .withOpacity(.05),
              blurRadius: 7,
              offset:
              const Offset(
                0,
                2,
              ),
            ),
          ],
        ),
        labelColor:
        isDark
            ? Colors.white
            : const Color(
          0xFF172033,
        ),
        unselectedLabelColor:
        const Color(
          0xFF8B929D,
        ),
        labelStyle:
        const TextStyle(
          fontSize: 11.5,
          fontWeight:
          FontWeight.w700,
        ),
        unselectedLabelStyle:
        const TextStyle(
          fontSize: 11.5,
          fontWeight:
          FontWeight.w500,
        ),
        tabs: const [
          Tab(
            text: 'Parts',
          ),
          Tab(
            text: 'Tires',
          ),
        ],
      ),
    );
  }
}




















class _MarketplaceTabContent extends StatelessWidget {
  final bool isDark;
  final bool isTiresTab;

  final TextEditingController searchController;
  final MarketplaceProvider marketplace;

  final void Function(String value) onSearchChanged;
  final Future<void> Function(String value) onSearchSubmitted;
  final Future<void> Function() onRefresh;

  const _MarketplaceTabContent({
    required this.isDark,
    required this.isTiresTab,
    required this.searchController,
    required this.marketplace,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onRefresh,
  });

  Future<void> _openFilters(
      BuildContext context,
      ) async {
    if (marketplace.filterOptions == null) {
      await marketplace.loadFilterOptions(
        productType:
        isTiresTab ? 'tire' : 'part',
      );
    }

    if (!context.mounted) return;

    final options =
        marketplace.filterOptions;

    if (options == null) {
      if (marketplace.errorMessage != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              marketplace.errorMessage!,
            ),
          ),
        );
      }

      return;
    }

    final result =
    await showModalBottomSheet<
        MarketplaceFilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MarketplaceFilterSheet(
          options: options,
          currentFilter:
          marketplace.filter,
          productType:
          isTiresTab
              ? 'tire'
              : 'part',
        );
      },
    );

    if (result == null ||
        !context.mounted) {
      return;
    }

    await marketplace.applyFilters(
      result,
    );
  }

  @override
  Widget build(BuildContext context) {
    final products =
        marketplace.products;

    final searchActive =
        marketplace.searchText
            .trim()
            .isNotEmpty;

    final browsingCategoryTree =
        !isTiresTab &&
            !marketplace.isViewingLeafProducts &&
            !marketplace.isAtCategoryRoot &&
            !searchActive;

    final showProducts =
    !browsingCategoryTree;

    String sectionTitle;

    if (searchActive) {
      sectionTitle = 'Search results';
    } else if (isTiresTab) {
      sectionTitle =
      marketplace.selectedCategoryId ==
          null
          ? 'Available tires'
          : 'Tires';
    } else if (marketplace
        .isViewingLeafProducts) {
      sectionTitle =
          marketplace.currentCategoryTitle;
    } else {
      sectionTitle = 'Available parts';
    }

    return RefreshIndicator(
      color: PartsPage.primaryOrange,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _MarketplaceSearchBar(
              controller:
              searchController,
              hint: isTiresTab
                  ? 'Search tire size or brand'
                  : 'Search parts, brand or number',
              isDark: isDark,
              isLoadingFilters:
              marketplace
                  .isLoadingFilters,
              onChanged:
              onSearchChanged,
              onSubmitted:
              onSearchSubmitted,
              onFilterTap: () {
                _openFilters(context);
              },
            ),
          ),

          if (marketplace.isLoading &&
              products.isNotEmpty)
            const SliverToBoxAdapter(
              child:
              LinearProgressIndicator(
                minHeight: 2,
                color:
                PartsPage
                    .primaryOrange,
                backgroundColor:
                Colors.transparent,
              ),
            ),

          SliverToBoxAdapter(
            child: _CategoryNavigator(
              marketplace:
              marketplace,
              isTiresTab:
              isTiresTab,
              isDark: isDark,
            ),
          ),

          if (!isTiresTab)
            const SliverToBoxAdapter(
              child:
              _CompactPartRequestBanner(),
            ),

          if (showProducts) ...[
            SliverToBoxAdapter(
              child: _ProductsSectionHeader(
                title: sectionTitle,
                searchActive:
                searchActive,
                searchText:
                marketplace
                    .searchText,
                isDark: isDark,
              ),
            ),

            if (marketplace.isLoading &&
                products.isEmpty)
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  26,
                ),
                sliver: SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 250,
                  ),
                  delegate:
                  SliverChildBuilderDelegate(
                        (_, __) {
                      return _ProductSkeleton(
                        isDark:
                        isDark,
                      );
                    },
                    childCount: 6,
                  ),
                ),
              )
            else if (marketplace
                .errorMessage !=
                null &&
                products.isEmpty)
              SliverToBoxAdapter(
                child: _MarketplaceErrorView(
                  message:
                  marketplace
                      .errorMessage!,
                  onRetry:
                  onRefresh,
                  isDark: isDark,
                ),
              )
            else if (products.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyProductsCard(
                    isDark: isDark,
                    isTire:
                    isTiresTab,
                    isSearch:
                    searchActive,
                    searchText:
                    marketplace
                        .searchText,
                    onClearSearch:
                    searchActive
                        ? () {
                      searchController
                          .clear();

                      onSearchSubmitted(
                        '',
                      );
                    }
                        : null,
                    onFilterTap:
                        () {
                      _openFilters(
                        context,
                      );
                    },
                  ),
                )
              else
                SliverPadding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    28,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 250,
                    ),
                    delegate:
                    SliverChildBuilderDelegate(
                          (
                          context,
                          index,
                          ) {
                        return _ProductCard(
                          product:
                          products[index],
                          isDark:
                          isDark,
                        );
                      },
                      childCount:
                      products.length,
                    ),
                  ),
                ),
          ] else
            SliverToBoxAdapter(
              child: _ChooseCategoryHint(
                isDark: isDark,
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// Search
// ============================================================

class _MarketplaceSearchBar
    extends StatelessWidget {
  final TextEditingController controller;

  final String hint;
  final bool isDark;
  final bool isLoadingFilters;

  final ValueChanged<String> onChanged;
  final Future<void> Function(String value)
  onSubmitted;
  final VoidCallback onFilterTap;

  const _MarketplaceSearchBar({
    required this.controller,
    required this.hint,
    required this.isDark,
    required this.isLoadingFilters,
    required this.onChanged,
    required this.onSubmitted,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? Colors.white.withOpacity(.08)
        : const Color(0xFFE1E4E9);

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        2,
        16,
        14,
      ),
      child: Row(
        children: [
          Expanded(
            child:
            ValueListenableBuilder<
                TextEditingValue>(
              valueListenable:
              controller,
              builder: (
                  context,
                  value,
                  _,
                  ) {
                return Container(
                  height: 46,
                  decoration:
                  BoxDecoration(
                    color: isDark
                        ? const Color(
                      0xFF151B25,
                    )
                        : Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                    border:
                    Border.all(
                      color:
                      borderColor,
                    ),
                  ),
                  child: TextField(
                    controller:
                    controller,
                    textInputAction:
                    TextInputAction
                        .search,
                    onChanged:
                    onChanged,
                    onSubmitted:
                        (text) {
                      onSubmitted(
                        text,
                      );
                    },
                    style:
                    TextStyle(
                      color: isDark
                          ? Colors.white
                          : const Color(
                        0xFF172033,
                      ),
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w500,
                    ),
                    decoration:
                    InputDecoration(
                      hintText:
                      hint,
                      hintStyle:
                      const TextStyle(
                        color:
                        Color(
                          0xFF989FAA,
                        ),
                        fontSize:
                        11.5,
                      ),
                      prefixIcon:
                      const Icon(
                        Icons
                            .search_rounded,
                        size: 20,
                        color:
                        Color(
                          0xFF747C88,
                        ),
                      ),
                      suffixIcon:
                      value.text
                          .isNotEmpty
                          ? IconButton(
                        onPressed:
                            () {
                          controller
                              .clear();

                          onSubmitted(
                            '',
                          );
                        },
                        icon:
                        const Icon(
                          Icons
                              .close_rounded,
                          size:
                          18,
                        ),
                      )
                          : null,
                      border:
                      InputBorder
                          .none,
                      contentPadding:
                      const EdgeInsets
                          .symmetric(
                        vertical: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(
            width: 9,
          ),

          Material(
            color: isDark
                ? const Color(
              0xFF151B25,
            )
                : Colors.white,
            borderRadius:
            BorderRadius.circular(
              14,
            ),
            child: InkWell(
              onTap:
              isLoadingFilters
                  ? null
                  : onFilterTap,
              borderRadius:
              BorderRadius.circular(
                14,
              ),
              child: Container(
                width: 46,
                height: 46,
                decoration:
                BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                  border:
                  Border.all(
                    color:
                    borderColor,
                  ),
                ),
                child:
                isLoadingFilters
                    ? const Center(
                  child:
                  SizedBox(
                    width: 17,
                    height: 17,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color:
                      PartsPage
                          .primaryOrange,
                    ),
                  ),
                )
                    : const Icon(
                  Icons
                      .tune_rounded,
                  size: 20,
                  color:
                  Color(
                    0xFF172033,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// Categories
// ============================================================

class _CategoryNavigator
    extends StatelessWidget {
  final MarketplaceProvider marketplace;
  final bool isTiresTab;
  final bool isDark;

  const _CategoryNavigator({
    required this.marketplace,
    required this.isTiresTab,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (isTiresTab) {
      return _TireCategories(
        marketplace:
        marketplace,
        isDark: isDark,
      );
    }

    return _PartCategories(
      marketplace:
      marketplace,
      isDark: isDark,
    );
  }
}


class _PartCategories
    extends StatelessWidget {
  final MarketplaceProvider marketplace;
  final bool isDark;

  const _PartCategories({
    required this.marketplace,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final categories =
        marketplace.categories;

    final leaf =
        marketplace.selectedLeafCategory;

    final pathParts =
    <String>[
      ...marketplace.categoryPath
          .map(
            (category) =>
        category.name,
      ),
      if (leaf != null)
        leaf.name,
    ];

    final breadcrumb =
    pathParts.join('  /  ');

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        14,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (marketplace
                  .canGoBackCategory) ...[
                Material(
                  color: isDark
                      ? Colors.white
                      .withOpacity(
                    .06,
                  )
                      : const Color(
                    0xFFE9ECF0,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                  child: InkWell(
                    onTap: () {
                      marketplace
                          .goBackCategory();
                    },
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                    child:
                    const SizedBox(
                      width: 34,
                      height: 34,
                      child: Icon(
                        Icons
                            .arrow_back_rounded,
                        size: 17,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 9,
                ),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      marketplace
                          .isAtCategoryRoot
                          ? 'Browse categories'
                          : marketplace
                          .currentCategoryTitle,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      TextStyle(
                        color: isDark
                            ? Colors.white
                            : const Color(
                          0xFF172033,
                        ),
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      marketplace
                          .isAtCategoryRoot
                          ? 'Find the exact type of part you need'
                          : breadcrumb,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF8A919C,
                        ),
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          if (marketplace
              .isViewingLeafProducts)
            _SelectedCategoryCard(
              name:
              marketplace
                  .currentCategoryTitle,
              isDark: isDark,
            )
          else if (categories.isEmpty)
            _NoCategoriesCard(
              isDark: isDark,
            )
          else
            SizedBox(
              height: 68,
              child:
              ListView.separated(
                scrollDirection:
                Axis.horizontal,
                itemCount:
                categories.length,
                separatorBuilder:
                    (_, __) =>
                const SizedBox(
                  width: 8,
                ),
                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final category =
                  categories[index];

                  return _CategoryCard(
                    category:
                    category,
                    isDark:
                    isDark,
                    onTap:
                        () {
                      marketplace
                          .openCategory(
                        category,
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}


class _TireCategories
    extends StatelessWidget {
  final MarketplaceProvider marketplace;
  final bool isDark;

  const _TireCategories({
    required this.marketplace,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final categories =
        marketplace.categories;

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        0,
        0,
        14,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
            const EdgeInsets.only(
              right: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        'Shop by tire type',
                        style:
                        TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(
                            0xFF172033,
                          ),
                          fontSize: 13,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      const Text(
                        'Choose a category or browse all tires',
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF8A919C,
                          ),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          SizedBox(
            height: 36,
            child:
            ListView.separated(
              scrollDirection:
              Axis.horizontal,
              padding:
              const EdgeInsets.only(
                right: 16,
              ),
              itemCount:
              categories.length + 1,
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
                if (index == 0) {
                  return _TireCategoryChip(
                    label: 'All tires',
                    selected:
                    marketplace
                        .selectedCategoryId ==
                        null,
                    isDark:
                    isDark,
                    onTap:
                        () {
                      marketplace
                          .selectCategory(
                        null,
                      );
                    },
                  );
                }

                final category =
                categories[
                index - 1];

                return _TireCategoryChip(
                  label:
                  category.name,
                  selected:
                  marketplace
                      .selectedCategoryId ==
                      category.id,
                  isDark:
                  isDark,
                  onTap:
                      () {
                    marketplace
                        .openCategory(
                      category,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _CategoryCard
    extends StatelessWidget {
  final ProductCategoryModel category;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? const Color(0xFF151B25)
          : Colors.white,
      borderRadius:
      BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(14),
        child: Container(
          width: 150,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              14,
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white
                  .withOpacity(
                .07,
              )
                  : const Color(
                0xFFE4E7EB,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration:
                BoxDecoration(
                  color: PartsPage
                      .primaryOrange
                      .withOpacity(
                    .10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
                child: Icon(
                  category.categoryType ==
                      'accessories'
                      ? Icons
                      .widgets_outlined
                      : Icons
                      .settings_outlined,
                  color:
                  PartsPage
                      .primaryOrange,
                  size: 17,
                ),
              ),

              const SizedBox(
                width: 9,
              ),

              Expanded(
                child: Text(
                  category.name,
                  maxLines: 2,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  TextStyle(
                    color: isDark
                        ? Colors.white
                        : const Color(
                      0xFF303846,
                    ),
                    fontSize: 10.5,
                    height: 1.2,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),

              if (category.hasChildren)
                const Icon(
                  Icons
                      .chevron_right_rounded,
                  size: 17,
                  color:
                  Color(
                    0xFF9AA1AB,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class _SelectedCategoryCard
    extends StatelessWidget {
  final String name;
  final bool isDark;

  const _SelectedCategoryCard({
    required this.name,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: PartsPage
            .primaryOrange
            .withOpacity(.08),
        borderRadius:
        BorderRadius.circular(
          13,
        ),
        border: Border.all(
          color: PartsPage
              .primaryOrange
              .withOpacity(.18),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons
                .check_circle_rounded,
            color:
            PartsPage.primaryOrange,
            size: 18,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              name,
              style:
              TextStyle(
                color: isDark
                    ? Colors.white
                    : const Color(
                  0xFF303846,
                ),
                fontSize: 11,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          const Text(
            'Selected',
            style:
            TextStyle(
              color:
              PartsPage.primaryOrange,
              fontSize: 9,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class _TireCategoryChip
    extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _TireCategoryChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? PartsPage.primaryOrange
          : isDark
          ? const Color(
        0xFF151B25,
      )
          : Colors.white,
      borderRadius:
      BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(999),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          alignment:
          Alignment.center,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              999,
            ),
            border: Border.all(
              color: selected
                  ? PartsPage
                  .primaryOrange
                  : isDark
                  ? Colors.white
                  .withOpacity(
                .07,
              )
                  : const Color(
                0xFFE3E6EA,
              ),
            ),
          ),
          child: Text(
            label,
            style:
            TextStyle(
              color: selected
                  ? Colors.white
                  : isDark
                  ? Colors.white
                  : const Color(
                0xFF4D5562,
              ),
              fontSize: 10,
              fontWeight:
              selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}


class _NoCategoriesCard
    extends StatelessWidget {
  final bool isDark;

  const _NoCategoriesCard({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(
          0xFF151B25,
        )
            : Colors.white,
        borderRadius:
        BorderRadius.circular(13),
      ),
      child: const Text(
        'No categories available here.',
        style: TextStyle(
          color:
          Color(0xFF8A919C),
          fontSize: 10.5,
        ),
      ),
    );
  }
}


// ============================================================
// Compact request CTA
// ============================================================

class _CompactPartRequestBanner
    extends StatelessWidget {
  const _CompactPartRequestBanner();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16,
      ),
      child: Container(
        padding:
        const EdgeInsets.all(
          13,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(
            0xFF151B25,
          )
              : const Color(
            0xFFFFF8F1,
          ),
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          border: Border.all(
            color: PartsPage
                .primaryOrange
                .withOpacity(.18),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration:
                  BoxDecoration(
                    color: PartsPage
                        .primaryOrange
                        .withOpacity(
                      .11,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      11,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .manage_search_rounded,
                    color:
                    PartsPage
                        .primaryOrange,
                    size: 20,
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
                        'Can’t find the right part?',
                        style:
                        TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(
                            0xFF172033,
                          ),
                          fontSize: 12,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      const Text(
                        'Send a request and receive vendor quotations.',
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF818995,
                          ),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 11,
            ),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child:
                    FilledButton.icon(
                      onPressed:
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                            const CreatePartRequestPage(),
                          ),
                        );
                      },
                      style:
                      FilledButton
                          .styleFrom(
                        backgroundColor:
                        PartsPage
                            .primaryOrange,
                        foregroundColor:
                        Colors.white,
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 10,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            11,
                          ),
                        ),
                      ),
                      icon:
                      const Icon(
                        Icons
                            .add_rounded,
                        size: 16,
                      ),
                      label:
                      const Text(
                        'Request part',
                        style:
                        TextStyle(
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: SizedBox(
                    height: 36,
                    child:
                    OutlinedButton.icon(
                      onPressed:
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                            const MyPartRequestsPage(),
                          ),
                        );
                      },
                      style:
                      OutlinedButton
                          .styleFrom(
                        foregroundColor:
                        isDark
                            ? Colors.white
                            : const Color(
                          0xFF4D5562,
                        ),
                        side:
                        BorderSide(
                          color: isDark
                              ? Colors.white
                              .withOpacity(
                            .10,
                          )
                              : const Color(
                            0xFFDBDEE3,
                          ),
                        ),
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 8,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            11,
                          ),
                        ),
                      ),
                      icon:
                      const Icon(
                        Icons
                            .receipt_long_outlined,
                        size: 15,
                      ),
                      label:
                      const Text(
                        'My requests',
                        style:
                        TextStyle(
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// Products heading
// ============================================================

class _ProductsSectionHeader
    extends StatelessWidget {
  final String title;
  final bool searchActive;
  final String searchText;
  final bool isDark;

  const _ProductsSectionHeader({
    required this.title,
    required this.searchActive,
    required this.searchText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        11,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  TextStyle(
                    color: isDark
                        ? Colors.white
                        : const Color(
                      0xFF172033,
                    ),
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                if (searchActive) ...[
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Results for “$searchText”',
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF8A919C,
                      ),
                      fontSize: 9.5,
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


// ============================================================
// Product card
// ============================================================

class _ProductCard
    extends StatelessWidget {
  final ProductModel product;
  final bool isDark;

  const _ProductCard({
    required this.product,
    required this.isDark,
  });

  Future<void> _openProduct(
      BuildContext context,
      ) async {
    final id = product.id;

    if (id == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductDetailsPage(
              productId: id,
            ),
      ),
    );

    if (!context.mounted) {
      return;
    }

    context
        .read<CartProvider>()
        .loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final description =
    product.isTire
        ? product.tireSpec
        ?.displaySize ??
        'Tire'
        : product
        .shortDescription ??
        'Car part';

    return Material(
      color: isDark
          ? const Color(0xFF151B25)
          : Colors.white,
      borderRadius:
      BorderRadius.circular(16),
      child: InkWell(
        onTap:
            () => _openProduct(
          context,
        ),
        borderRadius:
        BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white
                  .withOpacity(.06)
                  : const Color(
                0xFFE4E7EB,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _ProductImage(
                imageUrl:
                product.imageUrl,
                isTire:
                product.isTire,
                isDark: isDark,
                inStock:
                product.isInStock,
              ),

              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    10,
                    9,
                    10,
                    9,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        (product.brand ??
                            'Generic')
                            .toUpperCase(),
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        const TextStyle(
                          color:
                          PartsPage
                              .primaryOrange,
                          fontSize: 8.5,
                          letterSpacing: .4,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        product.name,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(
                            0xFF172033,
                          ),
                          fontSize: 11.5,
                          height: 1.25,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        description,
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF858D99,
                          ),
                          fontSize: 9,
                        ),
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration:
                            BoxDecoration(
                              color: product
                                  .isInStock
                                  ? const Color(
                                0xFF18A675,
                              )
                                  : const Color(
                                0xFFE05252,
                              ),
                              shape:
                              BoxShape
                                  .circle,
                            ),
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          Expanded(
                            child: Text(
                              product
                                  .isInStock
                                  ? '${product.stockQty} available'
                                  : 'Out of stock',
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              TextStyle(
                                color: product
                                    .isInStock
                                    ? const Color(
                                  0xFF158764,
                                )
                                    : const Color(
                                  0xFFE05252,
                                ),
                                fontSize: 8.5,
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              TextStyle(
                                color: isDark
                                    ? Colors
                                    .white
                                    : const Color(
                                  0xFF172033,
                                ),
                                fontSize: 13.5,
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),
                          ),

                          Container(
                            width: 28,
                            height: 28,
                            decoration:
                            BoxDecoration(
                              color: PartsPage
                                  .primaryOrange
                                  .withOpacity(
                                .10,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                9,
                              ),
                            ),
                            child:
                            const Icon(
                              Icons
                                  .arrow_forward_rounded,
                              color:
                              PartsPage
                                  .primaryOrange,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================
// Product image
// ============================================================

class _ProductImage
    extends StatelessWidget {
  final String imageUrl;
  final bool isTire;
  final bool isDark;
  final bool inStock;

  const _ProductImage({
    required this.imageUrl,
    required this.isTire,
    required this.isDark,
    required this.inStock,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 103,
      width: double.infinity,
      child: ClipRRect(
        borderRadius:
        const BorderRadius.vertical(
          top: Radius.circular(15),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder:
                    (
                    context,
                    child,
                    progress,
                    ) {
                  if (progress == null) {
                    return child;
                  }

                  return _ProductFallback(
                    isTire:
                    isTire,
                    isDark:
                    isDark,
                  );
                },
                errorBuilder:
                    (_, __, ___) {
                  return _ProductFallback(
                    isTire:
                    isTire,
                    isDark:
                    isDark,
                  );
                },
              )
            else
              _ProductFallback(
                isTire: isTire,
                isDark: isDark,
              ),

            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration:
                BoxDecoration(
                  color: inStock
                      ? const Color(
                    0xFF158764,
                  )
                      : const Color(
                    0xFFE05252,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    999,
                  ),
                ),
                child: Text(
                  inStock
                      ? 'IN STOCK'
                      : 'OUT OF STOCK',
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 7,
                    letterSpacing: .25,
                    fontWeight:
                    FontWeight.w700,
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


class _ProductFallback
    extends StatelessWidget {
  final bool isTire;
  final bool isDark;

  const _ProductFallback({
    required this.isTire,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: isDark
              ? const [
            Color(
              0xFF202838,
            ),
            Color(
              0xFF151B25,
            ),
          ]
              : const [
            Color(
              0xFFFFE8D1,
            ),
            Color(
              0xFFFFF7EF,
            ),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          isTire
              ? Icons
              .blur_circular_rounded
              : Icons
              .settings_outlined,
          size: 34,
          color:
          PartsPage.primaryOrange,
        ),
      ),
    );
  }
}


// ============================================================
// Category browsing hint
// ============================================================

class _ChooseCategoryHint
    extends StatelessWidget {
  final bool isDark;

  const _ChooseCategoryHint({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        24,
      ),
      child: Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(
          18,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(
            0xFF151B25,
          )
              : Colors.white,
          borderRadius:
          BorderRadius.circular(
            16,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
              BoxDecoration(
                color: PartsPage
                    .primaryOrange
                    .withOpacity(.09),
                shape:
                BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .account_tree_outlined,
                color:
                PartsPage
                    .primaryOrange,
                size: 22,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              'Choose a category',
              style:
              TextStyle(
                color: isDark
                    ? Colors.white
                    : const Color(
                  0xFF172033,
                ),
                fontSize: 12,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            const Text(
              'Select a more specific category above to see matching products.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color:
                Color(
                  0xFF8A919C,
                ),
                fontSize: 9.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// Empty state
// ============================================================

class _EmptyProductsCard
    extends StatelessWidget {
  final bool isDark;
  final bool isTire;
  final bool isSearch;
  final String searchText;

  final VoidCallback? onClearSearch;
  final VoidCallback onFilterTap;

  const _EmptyProductsCard({
    required this.isDark,
    required this.isTire,
    required this.isSearch,
    required this.searchText,
    required this.onClearSearch,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        28,
      ),
      child: Container(
        width: double.infinity,
        padding:
        const EdgeInsets.fromLTRB(
          22,
          28,
          22,
          26,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(
            0xFF151B25,
          )
              : Colors.white,
          borderRadius:
          BorderRadius.circular(
            18,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration:
              BoxDecoration(
                color: PartsPage
                    .primaryOrange
                    .withOpacity(.08),
                shape:
                BoxShape.circle,
              ),
              child: Icon(
                isSearch
                    ? Icons
                    .search_off_rounded
                    : isTire
                    ? Icons
                    .blur_circular_rounded
                    : Icons
                    .inventory_2_outlined,
                color:
                PartsPage
                    .primaryOrange,
                size: 27,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              isSearch
                  ? 'No matching products'
                  : isTire
                  ? 'No tires available'
                  : 'No parts available',
              style:
              TextStyle(
                color: isDark
                    ? Colors.white
                    : const Color(
                  0xFF172033,
                ),
                fontSize: 13,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              isSearch
                  ? 'We couldn’t find anything matching “$searchText”.'
                  : 'Try another category or adjust the filters.',
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                color:
                Color(
                  0xFF8A919C,
                ),
                fontSize: 10,
                height: 1.4,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            if (isSearch &&
                onClearSearch != null)
              SizedBox(
                height: 38,
                child:
                FilledButton(
                  onPressed:
                  onClearSearch,
                  style:
                  FilledButton
                      .styleFrom(
                    backgroundColor:
                    PartsPage
                        .primaryOrange,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        11,
                      ),
                    ),
                  ),
                  child:
                  const Text(
                    'Clear search',
                    style:
                    TextStyle(
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 38,
                child:
                OutlinedButton.icon(
                  onPressed:
                  onFilterTap,
                  icon:
                  const Icon(
                    Icons
                        .tune_rounded,
                    size: 16,
                  ),
                  label:
                  const Text(
                    'Adjust filters',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// Error state
// ============================================================

class _MarketplaceErrorView
    extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  final bool isDark;

  const _MarketplaceErrorView({
    required this.message,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        30,
      ),
      child: Container(
        padding:
        const EdgeInsets.all(
          24,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(
            0xFF151B25,
          )
              : Colors.white,
          borderRadius:
          BorderRadius.circular(
            18,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration:
              BoxDecoration(
                color: PartsPage
                    .primaryOrange
                    .withOpacity(.08),
                shape:
                BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .cloud_off_outlined,
                color:
                PartsPage
                    .primaryOrange,
                size: 26,
              ),
            ),

            const SizedBox(
              height: 13,
            ),

            Text(
              'Couldn’t load products',
              style:
              TextStyle(
                color: isDark
                    ? Colors.white
                    : const Color(
                  0xFF172033,
                ),
                fontSize: 13,
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
                  0xFF8A919C,
                ),
                fontSize: 10,
                height: 1.4,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            SizedBox(
              height: 38,
              child:
              FilledButton.icon(
                onPressed:
                    () {
                  onRetry();
                },
                style:
                FilledButton
                    .styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF172033,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      11,
                    ),
                  ),
                ),
                icon:
                const Icon(
                  Icons
                      .refresh_rounded,
                  size: 16,
                ),
                label:
                const Text(
                  'Try again',
                  style:
                  TextStyle(
                    fontSize: 10,
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


// ============================================================
// Loading cards
// ============================================================

class _ProductSkeleton
    extends StatelessWidget {
  final bool isDark;

  const _ProductSkeleton({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final base =
    isDark
        ? const Color(
      0xFF151B25,
    )
        : Colors.white;

    final placeholder =
    isDark
        ? Colors.white
        .withOpacity(.06)
        : const Color(
      0xFFECEEF1,
    );

    return Container(
      decoration: BoxDecoration(
        color: base,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            height: 103,
            decoration:
            BoxDecoration(
              color: placeholder,
              borderRadius:
              const BorderRadius
                  .vertical(
                top:
                Radius.circular(
                  16,
                ),
              ),
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.all(
              10,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _SkeletonLine(
                  width: 55,
                  color: placeholder,
                ),

                const SizedBox(
                  height: 8,
                ),

                _SkeletonLine(
                  width:
                  double.infinity,
                  color: placeholder,
                ),

                const SizedBox(
                  height: 6,
                ),

                _SkeletonLine(
                  width: 100,
                  color: placeholder,
                ),

                const SizedBox(
                  height: 19,
                ),

                _SkeletonLine(
                  width: 70,
                  color: placeholder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _SkeletonLine
    extends StatelessWidget {
  final double width;
  final Color color;

  const _SkeletonLine({
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        borderRadius:
        BorderRadius.circular(
          99,
        ),
      ),
    );
  }
}