import 'package:flutter/material.dart';

class RoadsidePage extends StatelessWidget {
  const RoadsidePage({super.key});

  // Brand colors
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
        color: const Color(0xFFF3F4F6), // نفس خلفية باقي الصفحات
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
                          'Roadside help',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stuck? We’ll get you moving again.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: subtleTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
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
                ],
              ),

              const SizedBox(height: 16),

              // Location & ETA card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const [
                      Color(0xFF111827),
                      Color(0xFF0F172A),
                    ]
                        : const [
                      Color(0xFFFFE0B2),
                      Color(0xFFFFF3E0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.20),
                      ),
                      child: const Icon(
                        Icons.electric_bolt_rounded,
                        color: primaryOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live GPS location ready',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Average arrival time in your area: 18–32 minutes.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: subtleTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Big SOS button
              Center(
                child: Column(
                  children: [
                    _BigRequestButton(isDark: isDark),
                    const SizedBox(height: 8),
                    Text(
                      'You’ll see your driver, ETA and live map once we match you.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtleTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Issue types
              Text(
                'What do you need help with?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _issues.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (ctx, index) {
                  final issue = _issues[index];
                  return _IssueCard(
                    icon: issue['icon'] as IconData,
                    label: issue['label'] as String,
                    desc: issue['desc'] as String,
                  );
                },
              ),

              const SizedBox(height: 24),

              // How it works
              Text(
                'How it works',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              _HowItWorksCard(
                isDark: isDark,
                subtleTextColor: subtleTextColor,
              ),

              const SizedBox(height: 24),

              // Recent roadside activity
              Text(
                'Recent roadside requests',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _recentRoadside.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final r = _recentRoadside[index];
                  return _RoadsideActivityTile(
                    icon: r['icon'] as IconData,
                    title: r['title'] as String,
                    subtitle: r['subtitle'] as String,
                    status: r['status'] as String,
                    statusColor: r['statusColor'] as Color,
                    isDark: isDark,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- dummy data ----------

const List<Map<String, Object>> _issues = [
  {
    'icon': Icons.local_shipping_rounded,
    'label': 'Tow truck',
    'desc': 'Can’t drive the car',
  },
  {
    'icon': Icons.tire_repair_rounded,
    'label': 'Flat tire',
    'desc': 'Need a tire change',
  },
  {
    'icon': Icons.car_crash_rounded,
    'label': 'Dead battery',
    'desc': 'Jumpstart required',
  },
  {
    'icon': Icons.lock_rounded,
    'label': 'Locked out',
    'desc': 'Keys inside the car',
  },
  {
    'icon': Icons.local_gas_station_rounded,
    'label': 'Out of gas',
    'desc': 'Fuel delivery',
  },
  {
    'icon': Icons.route_rounded,
    'label': 'Stuck / other',
    'desc': 'Winch or other issue',
  },
];

final List<Map<String, Object>> _recentRoadside = [
  {
    'icon': Icons.local_shipping_rounded,
    'title': 'Tow truck – downtown LA',
    'subtitle': 'Camry • 2.4 miles • 32 min total',
    'status': 'Completed',
    'statusColor': const Color(0xFF10B981),
  },
  {
    'icon': Icons.tire_repair_rounded,
    'title': 'Flat tire – I-405 shoulder',
    'subtitle': 'Spare tire installed • 18 min',
    'status': 'Completed',
    'statusColor': const Color(0xFF10B981),
  },
  {
    'icon': Icons.car_crash_rounded,
    'title': 'Battery jumpstart – office lot',
    'subtitle': 'ETA was 21 min • Evening',
    'status': 'Rated 5.0',
    'statusColor': const Color(0xFF2563EB),
  },
];

// ---------- sub-widgets ----------

class _BigRequestButton extends StatelessWidget {
  final bool isDark;

  const _BigRequestButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 210,
      height: 210,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RoadsidePage.primaryOrange,
            Color(0xFFFF9800),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: RoadsidePage.primaryOrange.withOpacity(0.35),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.electric_bolt_rounded,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Request help now',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'We’ll match you in seconds',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;

  const _IssueCard({
    required this.icon,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF020617) : Colors.white;

    return Material(
      color: bg,
      elevation: isDark ? 0 : 1,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {}, // static demo
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: RoadsidePage.primaryOrange.withOpacity(0.10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: RoadsidePage.primaryOrange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
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

class _HowItWorksCard extends StatelessWidget {
  final bool isDark;
  final Color subtleTextColor;

  const _HowItWorksCard({
    required this.isDark,
    required this.subtleTextColor,
  });

  Widget _step(
      BuildContext context, {
        required int number,
        required String title,
        required String desc,
      }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RoadsidePage.primaryOrange.withOpacity(0.12),
          ),
          child: Center(
            child: Text(
              '$number',
              style: theme.textTheme.labelSmall?.copyWith(
                color: RoadsidePage.primaryOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtleTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
        children: [
          _step(
            context,
            number: 1,
            title: 'Tell us what happened',
            desc:
            'Choose the issue and confirm your car and location details.',
          ),
          const SizedBox(height: 10),
          _step(
            context,
            number: 2,
            title: 'We match a nearby pro',
            desc:
            'We send your request to trusted roadside partners near you.',
          ),
          const SizedBox(height: 10),
          _step(
            context,
            number: 3,
            title: 'Track in real time',
            desc:
            'See ETA, live map, and driver details until the job is done.',
          ),
        ],
      ),
    );
  }
}

class _RoadsideActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final bool isDark;

  const _RoadsideActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
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
        borderRadius: BorderRadius.circular(14),
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
              icon,
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
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
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
              status,
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
