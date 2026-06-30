import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Brand system
  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);
  static const Color lightBackground = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : darkGrey;
    final subtleTextColor =
    isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);

    return SafeArea(
      child: Container(
        color: lightBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: primaryOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Verified',
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

              // Profile header card
              _ProfileHeaderCard(
                isDark: isDark,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),

              const SizedBox(height: 20),

              // Your cars
              const _SectionTitle(
                title: 'Your cars',
                actionText: 'Manage',
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 127,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (ctx, index) {
                    final car = _cars[index];
                    return _CarCard(
                      label: car['label'] as String,
                      plate: car['plate'] as String,
                      primary: index == 0,
                      isDark: isDark,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Payment methods
              const _SectionTitle(
                title: 'Payment methods',
                actionText: 'Edit',
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? const Color(0xFF020617) : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: const Column(
                  children: [
                    _SettingTile(
                      icon: Icons.credit_card_rounded,
                      iconColor: primaryOrange,
                      title: 'Visa ending in 2148',
                      subtitle: 'Default for parts & repairs',
                      trailingText: 'Primary',
                    ),
                    Divider(height: 1),
                    _SettingTile(
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: Color(0xFF10B981),
                      title: 'Apple Pay',
                      subtitle: 'Enabled on this device',
                      trailingIcon: Icons.chevron_right_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Preferences
              const _SectionTitle(
                title: 'Preferences',
                actionText: 'Edit',
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? const Color(0xFF020617) : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: [
                  _SwitchTile(
                    icon: Icons.notifications_active_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Push notifications',
                    subtitle: 'Job status, arrivals and offers',
                    value: true,
                    onChanged: null, // static demo
                  ),
                  const Divider(height: 1),
                  _SwitchTile(
                    icon: Icons.email_rounded,
                    iconColor: primaryOrange,
                    title: 'Email updates',
                    subtitle: 'Receipts and account activity',
                    value: true,
                    onChanged: null,
                  ),
                  const Divider(height: 1),
                  _SwitchTile(
                    icon: Icons.shield_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: 'Share location automatically',
                    subtitle: 'Faster roadside matching',
                    value: true,
                    onChanged: null,
                  ),
                ].let((tiles) => Column(children: tiles)),
              ),

              const SizedBox(height: 24),

              // Help & legal
              const _SectionTitle(
                title: 'Help & legal',
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? const Color(0xFF020617) : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: const Column(
                  children: [
                    _SettingTile(
                      icon: Icons.help_center_rounded,
                      iconColor: primaryOrange,
                      title: 'Help center',
                      subtitle: 'FAQs and support',
                      trailingIcon: Icons.chevron_right_rounded,
                    ),
                    Divider(height: 1),
                    _SettingTile(
                      icon: Icons.article_rounded,
                      iconColor: Color(0xFF6366F1),
                      title: 'Terms of service',
                      trailingIcon: Icons.chevron_right_rounded,
                    ),
                    Divider(height: 1),
                    _SettingTile(
                      icon: Icons.privacy_tip_rounded,
                      iconColor: Color(0xFF10B981),
                      title: 'Privacy policy',
                      trailingIcon: Icons.chevron_right_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout / footer
              Center(
                child: TextButton.icon(
                  onPressed: () {}, // static demo
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'App version 1.0.0-demo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtleTextColor,
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

// ---------- dummy data ----------

const List<Map<String, Object>> _cars = [
  {
    'label': '2019 Toyota Camry SE',
    'plate': '7XYZ214 • Primary',
  },
  {
    'label': '2016 Honda Civic LX',
    'plate': '8JKL902',
  },
];

// ---------- helpers ----------

// small extension just to allow .let(...) above without extra imports
extension _LetExt<T> on T {
  R let<R>(R Function(T) cb) => cb(this);
}

// ---------- sub widgets ----------

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;

  const _SectionTitle({
    required this.title,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        if (actionText != null)
          Text(
            actionText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: ProfilePage.primaryOrange,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color subtleTextColor;

  const _ProfileHeaderCard({
    required this.isDark,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            const Color(0xFF111827),
            const Color(0xFF020617),
          ]
              : [
            const Color(0xFFFFF3E0),
            const Color(0xFFFFE0B2),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.95),
            ),
            child: const Center(
              child: Text(
                'AJ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alex Johnson',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'alex.johnson@example.com',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtleTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '+1 (424) 555-0189',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtleTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withOpacity(0.95),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.edit_rounded,
                  size: 14,
                  color: ProfilePage.primaryOrange,
                ),
                const SizedBox(width: 4),
                Text(
                  'Edit',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ProfilePage.primaryOrange,
                    fontWeight: FontWeight.w600,
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

class _CarCard extends StatelessWidget {
  final String label;
  final String plate;
  final bool primary;
  final bool isDark;

  const _CarCard({
    required this.label,
    required this.plate,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = primary
        ? ProfilePage.primaryOrange
        : (isDark ? const Color(0xFF020617) : Colors.white);

    final textColor =
    primary ? Colors.white : (isDark ? Colors.white : const Color(0xFF111827));

    final subtle = primary
        ? Colors.white.withOpacity(0.9)
        : (isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280));

    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bg,
        border: Border.all(
          color: primary
              ? ProfilePage.primaryOrange
              : (isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.directions_car_filled_rounded,
            size: 26,
            color: primary ? Colors.white : ProfilePage.primaryOrange,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            plate,
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtle,
            ),
          ),
          const Spacer(),
          if (primary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withOpacity(0.15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Default car',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final IconData? trailingIcon;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor =
    isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);

    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: iconColor.withOpacity(0.12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: subtitleColor,
        ),
      )
          : null,
      trailing: trailingText != null
          ? Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: ProfilePage.primaryOrange.withOpacity(0.12),
        ),
        child: Text(
          trailingText!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: ProfilePage.primaryOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : (trailingIcon != null
          ? Icon(
        trailingIcon,
        size: 18,
        color: isDark
            ? Colors.white.withOpacity(0.7)
            : const Color(0xFF9CA3AF),
      )
          : null),
      onTap: () {}, // static demo
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor =
    isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);

    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: iconColor.withOpacity(0.12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: subtitleColor,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: ProfilePage.primaryOrange,
      ),
      onTap: () {},
    );
  }
}
