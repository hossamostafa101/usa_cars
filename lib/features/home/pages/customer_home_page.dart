import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/url_api.dart';
import '../data/models/customer_home_model.dart';
import '../providers/customer_home_provider.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onTapParts;
  final VoidCallback? onTapRoadside;
  final VoidCallback? onTapRepairs;
  final VoidCallback? onTapTires;

  const HomePage({
    super.key,
    this.onTapParts,
    this.onTapRoadside,
    this.onTapRepairs,
    this.onTapTires,
  });

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CustomerHomeProvider>().loadHome();
    });
  }

  void _handleQuickAction(String route) {
    switch (route) {
      case 'repair':
        widget.onTapRepairs?.call();
        break;
      case 'roadside':
        widget.onTapRoadside?.call();
        break;
      case 'tires':
        (widget.onTapTires?? widget.onTapRoadside)?.call();
        // ?? widget.onTapRoadside?.call();
        break;
      case 'marketplace':
      case 'parts':
        widget.onTapParts?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerHomeProvider>();
    final home = provider.home;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : HomePage.darkGrey;
    final subtleTextColor =
    isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: RefreshIndicator(
          onRefresh: provider.refreshHome,
          child: provider.isLoading && home == null
              ? const Center(child: CircularProgressIndicator())
              : provider.hasError && home == null
              ? _ErrorView(
            message: provider.errorMessage ?? 'Failed to load home',
            onRetry: provider.loadHome,
          )
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  userName: home?.user?.name ?? 'User',
                  unreadCount:
                  home?.unreadNotificationsCount ?? 0,
                  textColor: textColor,
                  subtleTextColor: subtleTextColor,
                ),

                const SizedBox(height: 16),

                _CurrentCarCard(
                  vehicleName:
                  home?.primaryVehicle?.displayName ??
                      'No car added yet',
                  vehicleDetails:
                  home?.primaryVehicle?.details ??
                      'Add your car to get better service',
                  isDark: isDark,
                  textColor: textColor,
                  subtleTextColor: subtleTextColor,
                ),

                const SizedBox(height: 20),

                if ((home?.banners ?? []).isNotEmpty)
                  _HeroBannerCarousel(
                    banners: home!.banners,
                  )
                else
                  const _StaticHeroBanner(),

                const SizedBox(height: 20),

                Text(
                  'Quick actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 10),

                _QuickActionsGrid(
                  actions: home?.quickActions ?? [],
                  isDark: isDark,
                  onTap: _handleQuickAction,
                ),

                const SizedBox(height: 24),

                _SectionHeader(
                  title: 'Featured offers',
                  actionText: 'View all',
                  textColor: textColor,
                ),

                const SizedBox(height: 12),

                if ((home?.featuredOffers ?? []).isNotEmpty)
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: home!.featuredOffers.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return _OfferCard(
                          offer: home.featuredOffers[index],
                          isDark: isDark,
                        );
                      },
                    ),
                  )
                else
                  _EmptyCard(
                    text: 'No offers available now',
                    isDark: isDark,
                  ),

                const SizedBox(height: 24),

                _SectionHeader(
                  title: 'Recent activity',
                  actionText: 'View all',
                  textColor: textColor,
                ),

                const SizedBox(height: 8),

                if ((home?.recentActivities ?? []).isNotEmpty)
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: home!.recentActivities.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _ActivityTile(
                        activity: home.recentActivities[index],
                        isDark: isDark,
                      );
                    },
                  )
                else
                  _EmptyCard(
                    text: 'No recent activity yet',
                    isDark: isDark,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;
  final int unreadCount;
  final Color textColor;
  final Color subtleTextColor;

  const _Header({
    required this.userName,
    required this.unreadCount,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, $userName',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What do you need today?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: subtleTextColor,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: HomePage.primaryOrange,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
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
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
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
      ],
    );
  }
}

class _CurrentCarCard extends StatelessWidget {
  final String vehicleName;
  final String vehicleDetails;
  final bool isDark;
  final Color textColor;
  final Color subtleTextColor;

  const _CurrentCarCard({
    required this.vehicleName,
    required this.vehicleDetails,
    required this.isDark,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF020617) : Colors.white,
        border: Border.all(
          color: HomePage.primaryOrange.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your car',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subtleTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicleName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicleDetails,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subtleTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: HomePage.primaryOrange.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              size: 26,
              color: HomePage.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final List<QuickActionModel> actions;
  final bool isDark;
  final void Function(String route) onTap;

  const _QuickActionsGrid({
    required this.actions,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final list = actions.isNotEmpty
        ? actions
        : const [
      QuickActionModel(
        key: 'repair',
        title: 'Car Repair',
        subtitle: 'Book a nearby repair shop',
        icon: 'repair',
        route: 'repair',
      ),
      QuickActionModel(
        key: 'roadside',
        title: 'Roadside Help',
        subtitle: 'Get help now',
        icon: 'roadside',
        route: 'roadside',
      ),
      QuickActionModel(
        key: 'parts',
        title: 'Parts',
        subtitle: 'Shop car parts',
        icon: 'parts',
        route: 'marketplace',
      ),
      QuickActionModel(
        key: 'tires',
        title: 'Tires',
        subtitle: 'Find and install tires',
        icon: 'tire',
        route: 'tires',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: list.map((action) {
            return SizedBox(
              width: itemWidth,
              child: _QuickActionCard(
                title: action.title,
                subtitle: action.subtitle,
                icon: _iconFromKey(action.icon),
                onTap: () => onTap(action.route),
                accentColor: _colorFromKey(action.key),
                isDark: isDark,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'repair':
        return Icons.build_circle_rounded;
      case 'roadside':
        return Icons.electric_bolt_rounded;
      case 'tire':
      case 'tires':
        return Icons.blur_circular_rounded;
      case 'parts':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  Color _colorFromKey(String key) {
    switch (key) {
      case 'repair':
        return HomePage.primaryOrange;
      case 'roadside':
        return const Color(0xFFFA9D3B);
      case 'tires':
        return const Color(0xFFFB923C);
      case 'parts':
        return const Color(0xFFEF6C00);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color accentColor;
  final bool isDark;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF020617) : Colors.white;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      elevation: isDark ? 0 : 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                  isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBannerCarousel extends StatefulWidget {
  final List<HomeBannerModel> banners;

  const _HeroBannerCarousel({
    required this.banners,
  });

  @override
  State<_HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<_HeroBannerCarousel> {
  final PageController pageController = PageController(viewportFraction: 0.90);
  int currentPage = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() => currentPage = index);
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _BannerCard(
                  title: banner.title ?? '',
                  subtitle: banner.subtitle ?? '',
                  imageUrl: UrlApi.assetUrl(banner.imagePath),
                  tag: 'Car care made easy',
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.banners.length, (index) {
                final isActive = index == currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: isActive ? 18 : 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color:
                    isActive ? Colors.white : Colors.white.withOpacity(0.4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticHeroBanner extends StatelessWidget {
  const _StaticHeroBanner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 170,
      child: _BannerCard(
        title: 'All your car services in one app',
        subtitle: 'Repair, tires, body work and more – just a few taps away.',
        imageUrl:
        'https://repairsmith-prod-wordpress.s3.amazonaws.com/2022/09/car-repair.jpg',
        tag: 'Car care made easy',
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String tag;

  const _BannerCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF374151),
              ),
            )
          else
            Container(color: const Color(0xFF374151)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withOpacity(0.16),
                  ),
                  child: Text(
                    tag,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.88),
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

class _OfferCard extends StatelessWidget {
  final FeaturedOfferModel offer;
  final bool isDark;

  const _OfferCard({
    required this.offer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFromOfferType(offer.offerType);
    final baseBg = isDark ? const Color(0xFF020617) : Colors.white;

    return Container(
      width: 230,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: baseBg,
        border: Border.all(color: color.withOpacity(0.20), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((offer.discountText ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: color.withOpacity(0.12),
              ),
              child: Text(
                offer.discountText!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            offer.title ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            offer.description ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? Colors.white.withOpacity(0.75)
                  : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromOfferType(String? type) {
    switch (type) {
      case 'repair':
        return HomePage.primaryOrange;
      case 'roadside':
        return const Color(0xFFFB923C);
      case 'parts':
        return const Color(0xFFEF6C00);
      case 'tires':
        return const Color(0xFF6B7280);
      default:
        return HomePage.primaryOrange;
    }
  }
}

class _ActivityTile extends StatelessWidget {
  final RecentActivityModel activity;
  final bool isDark;

  const _ActivityTile({
    required this.activity,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(activity.status);
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
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: statusColor.withOpacity(0.12),
            ),
            child: Icon(
              _activityIcon(activity.type),
              size: 20,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                    isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: statusColor.withOpacity(0.12),
            ),
            child: Text(
              activity.status,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _activityIcon(String type) {
    switch (type) {
      case 'repair':
        return Icons.home_repair_service_rounded;
      case 'roadside':
        return Icons.electric_bolt_rounded;
      case 'order':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return const Color(0xFF10B981);
      case 'confirmed':
      case 'shipped':
      case 'on_the_way':
        return const Color(0xFF2563EB);
      case 'pending':
      case 'requested':
      case 'quoted':
        return const Color(0xFFF59E0B);
      case 'cancelled':
      case 'rejected':
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return HomePage.primaryOrange;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final Color textColor;

  const _SectionHeader({
    required this.title,
    required this.actionText,
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
          actionText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HomePage.primaryOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  final bool isDark;

  const _EmptyCard({
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
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