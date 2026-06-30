import 'package:flutter/material.dart';

class PartsPage extends StatelessWidget {
  const PartsPage({super.key});

  // نفس ألوان الهوية في اللوجين / الهوم
  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : darkGrey;
    final subtleTextColor =
    isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);

    return SafeArea(
      child: DefaultTabController(
        length: 2, // Parts + Tires
        child: Container(
          color: const Color(0xFFF3F4F6), // خلفية رمادي فاتح
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Padding(
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.white,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.10)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.directions_car_rounded,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '2019 Camry',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tabs: Parts / Tires (تصميم أبسط وأنضف)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: primaryOrange,
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

              // محتوى كل تاب
              Expanded(
                child: TabBarView(
                  children: [
                    // تبويب قطع الغيار
                    _PartsTabContent(
                      isDark: isDark,
                      textColor: textColor,
                      subtleTextColor: subtleTextColor,
                      isTiresTab: false,
                    ),
                    // تبويب الكاوتش
                    _PartsTabContent(
                      isDark: isDark,
                      textColor: textColor,
                      subtleTextColor: subtleTextColor,
                      isTiresTab: true,
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

/// محتوى كل تاب (Parts / Tires)
class _PartsTabContent extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color subtleTextColor;
  final bool isTiresTab;

  const _PartsTabContent({
    required this.isDark,
    required this.textColor,
    required this.subtleTextColor,
    required this.isTiresTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final categories =
    isTiresTab ? _tireCategories : _categories;
    final products =
    isTiresTab ? _tires : _parts;
    final brands =
    isTiresTab ? _tireBrands : _brands;

    final sectionTitle = isTiresTab
        ? 'Top tire picks for your car'
        : 'Top picks for your Camry';

    final searchHint = isTiresTab
        ? 'Search by tire size or brand'
        : 'Search by part, number or VIN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search + filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true, // static demo
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor:
                    isDark ? const Color(0xFF020617) : Colors.white,
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
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
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
                child: const Icon(Icons.tune_rounded, size: 20),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Categories chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, index) {
              final cat = categories[index];
              return _CategoryChip(
                label: cat['label'] as String,
                icon: cat['icon'] as IconData,
                selected: index == 0, // أول واحد selected كديمو
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Top picks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sectionTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'View all',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: PartsPage.primaryOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Grid of parts / tires
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
                    final part = products[index];
                    return _PartCard(
                      title: part['title'] as String,
                      brand: part['brand'] as String,
                      compat: part['compat'] as String,
                      price: part['price'] as String,
                      tag: part['tag'] as String,
                      rating: part['rating'] as double,
                      reviews: part['reviews'] as int,
                      shipsIn: part['shipsIn'] as String,
                      isDark: isDark,
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Popular brands
                Text(
                  'Popular brands',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: brands.map((b) {
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
                        b,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- dummy data ----------

// قطع الغيار
const List<Map<String, Object>> _categories = [
  {'label': 'Brakes', 'icon': Icons.stop_circle_rounded},
  {'label': 'Engine', 'icon': Icons.settings_rounded},
  {'label': 'Suspension', 'icon': Icons.directions_car_filled_rounded},
  {'label': 'Electrical', 'icon': Icons.bolt_rounded},
  {'label': 'Body & lights', 'icon': Icons.light_mode_rounded},
  {'label': 'Fluids & filters', 'icon': Icons.oil_barrel_rounded},
];

final List<Map<String, Object>> _parts = [
  {
    'title': 'Front brake pads',
    'brand': 'Brembo',
    'compat': 'Fits 2018–2021 Camry',
    'price': '\$89.99',
    'tag': 'Best seller',
    'rating': 4.8,
    'reviews': 214,
    'shipsIn': 'Ships in 24h',
  },
  {
    'title': 'Engine air filter',
    'brand': 'Bosch',
    'compat': '2.5L engines',
    'price': '\$23.40',
    'tag': 'Fast shipping',
    'rating': 4.6,
    'reviews': 97,
    'shipsIn': 'Ships today',
  },
  {
    'title': 'Synthetic engine oil',
    'brand': 'Mobil 1',
    'compat': '0W-20 • 5 qt',
    'price': '\$39.50',
    'tag': 'Bundle deal',
    'rating': 4.9,
    'reviews': 361,
    'shipsIn': 'Local pickup',
  },
  {
    'title': 'All-weather wiper set',
    'brand': 'Rain-X',
    'compat': 'Front pair • 26/18"',
    'price': '\$29.90',
    'tag': 'Top rated',
    'rating': 4.1,
    'reviews': 30,
    'shipsIn': 'Ships in 2 days',
  },
];

const List<String> _brands = [
  'Brembo',
  'Bosch',
  'Mobil 1',
  'ACDelco',
  'Monroe',
  'NGK',
  'Rain-X',
];

// الكاوتش (Tires)
const List<Map<String, Object>> _tireCategories = [
  {'label': 'All-season', 'icon': Icons.blur_circular_rounded},
  {'label': 'Performance', 'icon': Icons.speed_rounded},
  {'label': 'Off-road', 'icon': Icons.terrain_rounded},
  {'label': 'Run-flat', 'icon': Icons.shield_rounded},
];

final List<Map<String, Object>> _tires = [
  {
    'title': '225/50 R17 all-season tire',
    'brand': 'Michelin',
    'compat': 'Fits many midsize sedans',
    'price': '\$129.00',
    'tag': 'Best seller',
    'rating': 4.7,
    'reviews': 189,
    'shipsIn': 'Ships in 24h',
  },
  {
    'title': '215/55 R17 performance tire',
    'brand': 'Pirelli',
    'compat': 'Sport & performance',
    'price': '\$149.90',
    'tag': 'New arrival',
    'rating': 4.5,
    'reviews': 76,
    'shipsIn': 'Ships today',
  },
  {
    'title': '235/60 R18 SUV tire',
    'brand': 'Bridgestone',
    'compat': 'Crossovers & SUVs',
    'price': '\$159.50',
    'tag': 'Off-road ready',
    'rating': 4.6,
    'reviews': 98,
    'shipsIn': 'Local pickup',
  },
  {
    'title': '205/55 R16 budget tire',
    'brand': 'Hankook',
    'compat': 'Compact cars',
    'price': '\$89.00',
    'tag': 'Best value',
    'rating': 4.2,
    'reviews': 54,
    'shipsIn': 'Ships in 2 days',
  },
];

const List<String> _tireBrands = [
  'Michelin',
  'Pirelli',
  'Bridgestone',
  'Goodyear',
  'Hankook',
];

// ---------- sub widgets ----------

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
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

    return Container(
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
    );
  }
}

class _PartCard extends StatelessWidget {
  final String title;
  final String brand;
  final String compat;
  final String price;
  final String tag;
  final double rating;
  final int reviews;
  final String shipsIn;
  final bool isDark;

  const _PartCard({
    required this.title,
    required this.brand,
    required this.compat,
    required this.price,
    required this.tag,
    required this.rating,
    required this.reviews,
    required this.shipsIn,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseBg = isDark ? const Color(0xFF020617) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: baseBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top image placeholder
          Container(
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
            child: Center(
              child: Icon(
                Icons.build_rounded,
                size: 30,
                color: isDark
                    ? Colors.white.withOpacity(0.9)
                    : PartsPage.primaryOrange,
              ),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color:
                    PartsPage.primaryOrange.withOpacity(0.10),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: PartsPage.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                    isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  brand,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  compat,
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
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style:
                      theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviews)',
                      style:
                      theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      shipsIn,
                      style:
                      theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.75)
                            : const Color(0xFF059669),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      price,
                      style:
                      theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF111827),
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
                        color: PartsPage.primaryOrange
                            .withOpacity(0.10),
                      ),
                      child: Text(
                        'View',
                        style:
                        theme.textTheme.labelSmall?.copyWith(
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
    );
  }
}
