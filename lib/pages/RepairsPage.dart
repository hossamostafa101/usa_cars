import 'package:flutter/material.dart';

class RepairsPage extends StatelessWidget {
  const RepairsPage({super.key});

  // Brand colors (موحّدة مع باقي الصفحات)
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
      child: Container(
        color: const Color(0xFFF3F4F6), // خلفية رمادي فاتح مثل Home/Parts/Roadside
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Repairs & maintenance',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find certified shops and book a time that works for you.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: subtleTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.10)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Los Angeles, CA',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '2019 Camry SE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: subtleTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search bar
              TextField(
                readOnly: true, // static demo
                decoration: InputDecoration(
                  hintText: 'Search shops or services (e.g. “oil change”)',
                  prefixIcon: const Icon(Icons.search_rounded),
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
                      color: primaryOrange,
                      width: 1.4,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),

              const SizedBox(height: 16),

              // Service categories
              Text(
                'Popular services',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _serviceCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, index) {
                    final s = _serviceCategories[index];
                    return _ServiceChip(
                      label: s['label'] as String,
                      icon: s['icon'] as IconData,
                      selected: index == 0,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Map preview (static)
              _MapPreviewCard(isDark: isDark),

              const SizedBox(height: 20),

              // Recommended shops
              /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended shops near you',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'View all',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: primaryOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _shops.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final shop = _shops[index];
                  return _ShopCard(
                    name: shop['name'] as String,
                    distance: shop['distance'] as String,
                    rating: shop['rating'] as double,
                    reviews: shop['reviews'] as int,
                    nextSlot: shop['nextSlot'] as String,
                    services: shop['services'] as String,
                    tag: shop['tag'] as String,
                    isDark: isDark,
                  );
                },
              ),

              const SizedBox(height: 24),*/





              // ===== Workshops: general repair & maintenance =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workshops – repair & maintenance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'View all',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: primaryOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Mechanical, electrical and general service workshops.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtleTextColor,
                ),
              ),
              const SizedBox(height: 10),

              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _repairShops.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final shop = _repairShops[index];
                  return _ShopCard(
                    name: shop['name'] as String,
                    distance: shop['distance'] as String,
                    rating: shop['rating'] as double,
                    reviews: shop['reviews'] as int,
                    nextSlot: shop['nextSlot'] as String,
                    services: shop['services'] as String,
                    tag: shop['tag'] as String,
                    isDark: isDark,
                  );
                },
              ),

              const SizedBox(height: 24),

// ===== Body repair (سمكرة) workshops =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Body repair (سمكرة) workshops',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'View all',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: primaryOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Paint, dents, body work and accident repair specialists.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtleTextColor,
                ),
              ),
              const SizedBox(height: 10),

              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _bodyRepairShops.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final shop = _bodyRepairShops[index];
                  return _ShopCard(
                    name: shop['name'] as String,
                    distance: shop['distance'] as String,
                    rating: shop['rating'] as double,
                    reviews: shop['reviews'] as int,
                    nextSlot: shop['nextSlot'] as String,
                    services: shop['services'] as String,
                    tag: shop['tag'] as String,
                    isDark: isDark,
                  );
                },
              ),







              // Booking week section
              Text(
                'Book for this week',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, index) {
                    final d = _days[index];
                    return _DayChip(
                      label: d['label'] as String,
                      date: d['date'] as String,
                      selected: index == 1, // example: today
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              _TimeSlotCard(isDark: isDark, subtleTextColor: subtleTextColor),
            ],
          ),
        ),
      ),
    );
  }
}

// -------- dummy data --------

const List<Map<String, Object>> _serviceCategories = [
  {'label': 'Oil change', 'icon': Icons.oil_barrel_rounded},
  {'label': 'Diagnostics', 'icon': Icons.device_unknown_rounded},
  {'label': 'Brakes', 'icon': Icons.stop_circle_rounded},
  {'label': 'Tires & alignment', 'icon': Icons.tire_repair_rounded},
  {'label': 'A/C service', 'icon': Icons.ac_unit_rounded},
  {'label': 'General repair', 'icon': Icons.build_rounded},
];

final List<Map<String, Object>> _shops = [
  {
    'name': 'Prime Auto Care',
    'distance': '0.9 mi • 8 min',
    'rating': 4.8,
    'reviews': 187,
    'nextSlot': 'Today • 3:30 PM',
    'services': 'Oil change • Brakes • Diagnostics',
    'tag': 'Certified partner',
  },
  {
    'name': 'Downtown Tire & Brake',
    'distance': '1.4 mi • 11 min',
    'rating': 4.7,
    'reviews': 243,
    'nextSlot': 'Today • 5:00 PM',
    'services': 'Tires • Alignment • Brake service',
    'tag': 'Same-day slots',
  },
  {
    'name': 'Sunset Motors Service',
    'distance': '2.2 mi • 15 min',
    'rating': 4.6,
    'reviews': 129,
    'nextSlot': 'Today • 10:00 AM',
    'services': 'General repair • A/C • Diagnostics',
    'tag': 'Popular in your area',
  },
];

const List<Map<String, Object>> _days = [
  {'label': 'Mon', 'date': '11'},
  {'label': 'Tue', 'date': '12'},
  {'label': 'Wed', 'date': '13'},
  {'label': 'Thu', 'date': '14'},
  {'label': 'Fri', 'date': '15'},
];


// ورش صيانة عامة (ميكانيكا / كهرباء / A/C ...)
final List<Map<String, Object>> _repairShops = [
  {
    'name': 'Prime Auto Care',
    'distance': '0.9 mi • 8 min',
    'rating': 4.8,
    'reviews': 187,
    'nextSlot': 'Today • 3:30 PM',
    'services': 'Oil change • Brakes • Diagnostics',
    'tag': 'General workshop',
  },
  {
    'name': 'Sunset Motors Service',
    'distance': '2.2 mi • 15 min',
    'rating': 4.6,
    'reviews': 129,
    'nextSlot': 'Today • 10:00 AM',
    'services': 'General repair • A/C • Diagnostics',
    'tag': 'Multi-service workshop',
  },
];

// ورش سمكرة وبودي
final List<Map<String, Object>> _bodyRepairShops = [
  {
    'name': 'City Body & Paint',
    'distance': '1.1 mi • 9 min',
    'rating': 4.7,
    'reviews': 154,
    'nextSlot': 'Today • 4:00 PM',
    'services': 'Body repair • Paint • Dent removal',
    'tag': 'Body repair specialist',
  },
  {
    'name': 'Elite Collision Center',
    'distance': '2.8 mi • 18 min',
    'rating': 4.9,
    'reviews': 203,
    'nextSlot': 'Today • 8:30 AM',
    'services': 'Accident repair • Frame alignment',
    'tag': 'Insurance approved',
  },
];


// ------- sub widgets -------

class _ServiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const _ServiceChip({
    required this.label,
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = selected
        ? RepairsPage.primaryOrange.withOpacity(0.16)
        : isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFF3F4F6);

    final textColor = selected
        ? RepairsPage.primaryOrange
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

class _MapPreviewCard extends StatelessWidget {
  final bool isDark;

  const _MapPreviewCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isDark ? const Color(0xFF020617) : const Color(0xFFF3F4F6);

    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: bg,
        border: Border.all(
          color:
          isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Stack(
        children: [
          // Fake map pattern
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.20 : 0.35,
              child: GridPaper(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : const Color(0xFF9CA3AF),
                divisions: 3,
                interval: 40,
                subdivisions: 1,
              ),
            ),
          ),
          // Pins (main pin برتقالي)
          const Positioned(
            left: 60,
            top: 40,
            child: _MapPin(primary: true),
          ),
          const Positioned(
            right: 40,
            bottom: 38,
            child: _MapPin(primary: false),
          ),
          const Positioned(
            left: 120,
            bottom: 35,
            child: _MapPin(primary: false),
          ),
          // Info
          Positioned(
            left: 14,
            bottom: 14,
            right: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.black.withOpacity(0.60),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_searching_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Showing shops within 5 miles',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                    color: Colors.black.withOpacity(0.60),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Open map',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final bool primary;

  const _MapPin({required this.primary});

  @override
  Widget build(BuildContext context) {
    final color =
    primary ? RepairsPage.primaryOrange : const Color(0xFFFF9800);

    return Column(
      children: [
        Icon(
          Icons.location_on_rounded,
          color: color,
          size: primary ? 30 : 24,
        ),
        if (primary)
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: color.withOpacity(0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _ShopCard extends StatelessWidget {
  final String name;
  final String distance;
  final double rating;
  final int reviews;
  final String nextSlot;
  final String services;
  final String tag;
  final bool isDark;

  const _ShopCard({
    required this.name,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.nextSlot,
    required this.services,
    required this.tag,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isDark ? const Color(0xFF020617) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
          isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar / logo placeholder
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: RepairsPage.primaryOrange.withOpacity(0.10),
            ),
            child: const Icon(
              Icons.home_repair_service_rounded,
              size: 22,
              color: RepairsPage.primaryOrange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  distance,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                // Rating row
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
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviews)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: const Color(0xFF10B981).withOpacity(0.10),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF047857),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  services,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Next available: $nextSlot',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.8)
                            : const Color(0xFF6B7280),
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
                        color: RepairsPage.primaryOrange.withOpacity(0.10),
                      ),
                      child: Text(
                        'Book',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: RepairsPage.primaryOrange,
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

class _DayChip extends StatelessWidget {
  final String label;
  final String date;
  final bool selected;

  const _DayChip({
    required this.label,
    required this.date,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = selected
        ? RepairsPage.primaryOrange
        : isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white;
    final textColor =
    selected ? Colors.white : (isDark ? Colors.white : const Color(0xFF111827));
    final subtle = selected
        ? Colors.white.withOpacity(0.9)
        : (isDark
        ? Colors.white.withOpacity(0.7)
        : const Color(0xFF6B7280));

    return Container(
      width: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bg,
        border: Border.all(
          color: selected
              ? RepairsPage.primaryOrange
              : (isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFFE5E7EB)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: subtle,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSlotCard extends StatelessWidget {
  final bool isDark;
  final Color subtleTextColor;

  const _TimeSlotCard({
    required this.isDark,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isDark ? const Color(0xFF020617) : const Color(0xFFF9FAFB);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bg,
        border: Border.all(
          color:
          isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sample booking',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prime Auto Care • Oil change & inspection',
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtleTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16),
              const SizedBox(width: 6),
              Text(
                'Tue, 12 • 3:30 PM – 4:15 PM',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF374151),
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
                  color: RepairsPage.primaryOrange.withOpacity(0.10),
                ),
                child: Text(
                  'Confirm',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: RepairsPage.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
