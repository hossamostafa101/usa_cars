import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/features/notifications/pages/notifications_page.dart';
import 'package:talabatfresh/features/part_requests/pages/my_part_requests_page.dart';
import 'package:talabatfresh/features/profile/pages/privacy_policy_page.dart';
import 'package:talabatfresh/features/repair/pages/repairs_page.dart';
import 'package:talabatfresh/features/roadside/pages/roadside_page.dart';
import 'package:talabatfresh/features/vehicles/pages/cars_management_page.dart';
import 'package:talabatfresh/providers/auth_provider.dart';
import '../../marketplace/page/orders_page.dart';
import '../../vehicles/data/models/vehicle_model.dart';
import '../providers/profile_provider.dart';
import 'addresses_page.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);
  static const Color lightBackground = Color(0xFFF3F4F6);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
          (_) => false,
    );
  }

  Future<void> _openProfilePage(
      Widget page,
      ) async {
    final changed =
    await Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) =>
        page,
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      await context
          .read<ProfileProvider>()
          .refreshProfile();
    }
  }



  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : ProfilePage.darkGrey;
    final subtleTextColor =
    isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);

    return SafeArea(
      child: Scaffold(
        backgroundColor: ProfilePage.lightBackground,
        body: RefreshIndicator(
          onRefresh: provider.refreshProfile,
          child: provider.isLoading && provider.user == null
              ? const Center(child: CircularProgressIndicator())
              : provider.errorMessage != null && provider.user == null
              ? _ErrorView(
            message: provider.errorMessage!,
            onRetry: provider.loadProfile,
          )
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  textColor: textColor,
                  isVerified: provider.user?.isActive ?? false,
                ),

                const SizedBox(height: 16),

                _ProfileHeaderCard(
                  name:
                  provider.user?.name ??
                      'User',
                  email:
                  provider.user?.email ??
                      '',
                  phone:
                  provider.user?.phone ??
                      '',
                  isDark:
                  isDark,
                  textColor:
                  textColor,
                  subtleTextColor:
                  subtleTextColor,
                  onEdit: () {
                    _openProfilePage(
                      const EditProfilePage(),
                    );
                  },
                ),

                const SizedBox(height: 20),

                _SectionTitle(
                  title: 'Your cars',
                  actionText: 'Manage',
                  onActionTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CarsManagementPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                if (provider.vehicles.isNotEmpty)
                  SizedBox(
                    height: 127,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.vehicles.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final vehicle = provider.vehicles[index];

                        return _CarCard(
                          vehicle: vehicle,
                          isDark: isDark,
                        );
                      },
                    ),
                  )
                else
                  _EmptyCard(
                    text: 'No cars added yet',
                    isDark: isDark,
                  ),

                const SizedBox(height: 24),

                const SizedBox(
                  height: 24,
                ),

                const _SectionTitle(
                  title: 'Account',
                ),

                const SizedBox(
                  height: 8,
                ),

                _CardBox(
                  isDark:
                  isDark,
                  child:
                  Column(
                    children: [
                      _SettingTile(
                        icon:
                        Icons.person_outline_rounded,
                        iconColor:
                        ProfilePage.primaryOrange,
                        title:
                        'Personal information',
                        subtitle:
                        'Name, phone and profile details',
                        trailingIcon:
                        Icons.chevron_right_rounded,
                        onTap: () {
                          _openProfilePage(
                            const EditProfilePage(),
                          );
                        },
                      ),

                      const Divider(
                        height:
                        1,
                      ),

                      _SettingTile(
                        icon:
                        Icons.lock_outline_rounded,
                        iconColor:
                        const Color(
                          0xFF6366F1,
                        ),
                        title:
                        'Change password',
                        subtitle:
                        'Update your account password',
                        trailingIcon:
                        Icons.chevron_right_rounded,
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (_) =>
                              const ChangePasswordPage(),
                            ),
                          );
                        },
                      ),

                      const Divider(
                        height:
                        1,
                      ),

                      _SettingTile(
                        icon:
                        Icons.location_on_outlined,
                        iconColor:
                        const Color(
                          0xFF10B981,
                        ),
                        title:
                        'Saved addresses',
                        subtitle:
                        'Home, work and service locations',
                        trailingIcon:
                        Icons.chevron_right_rounded,
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (_) =>
                              const AddressesPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                const _SectionTitle(
                  title: 'Activity',
                ),

                const SizedBox(
                  height: 8,
                ),

                _CardBox(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: Icons.shopping_bag_outlined,
                        iconColor: const Color(0xFF6366F1),
                        title: 'Orders',
                        subtitle: 'Marketplace purchases and order status',
                        trailingIcon: Icons.chevron_right_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OrdersPage(),
                            ),
                          );
                        },
                      ),

                      const Divider(height: 1),

                      _SettingTile(
                        icon: Icons.request_quote_outlined,
                        iconColor: const Color(0xFF0EA5E9),
                        title: 'Part requests',
                        subtitle: 'Requests sent to parts sellers',
                        trailingIcon: Icons.chevron_right_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MyPartRequestsPage(),
                            ),
                          );
                        },
                      ),

                      const Divider(height: 1),

                      _SettingTile(
                        icon: Icons.build_outlined,
                        iconColor: const Color(0xFF10B981),
                        title: 'Repair services',
                        subtitle: 'Workshops and repair requests',
                        trailingIcon: Icons.chevron_right_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RepairsPage(),
                            ),
                          );
                        },
                      ),

                      const Divider(height: 1),

                      _SettingTile(
                        icon: Icons.local_shipping_outlined,
                        iconColor: ProfilePage.primaryOrange,
                        title: 'Roadside assistance',
                        subtitle: 'Towing and roadside requests',
                        trailingIcon: Icons.chevron_right_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RoadsidePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                const _SectionTitle(
                  title: 'App',
                ),

                const SizedBox(
                  height: 8,
                ),

                _CardBox(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: Icons.notifications_none_rounded,
                        iconColor: ProfilePage.primaryOrange,
                        title: 'Notifications',
                        subtitle: 'View your recent notifications',
                        trailingIcon: Icons.chevron_right_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                const _SectionTitle(
                  title: 'Preferences',
                ),

                const SizedBox(height: 8),

                _CardBox(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _SwitchTile(
                        icon: Icons.notifications_active_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Push notifications',
                        subtitle: 'Orders, repairs and roadside updates',
                        value: provider.pushNotificationsEnabled,
                        onChanged: provider.setPushNotificationsEnabled,
                      ),

                      const Divider(height: 1),

                      _SwitchTile(
                        icon: Icons.email_outlined,
                        iconColor: ProfilePage.primaryOrange,
                        title: 'Email updates',
                        subtitle: 'Receipts and account activity',
                        value: provider.emailUpdatesEnabled,
                        onChanged: provider.setEmailUpdatesEnabled,
                      ),

                      const Divider(height: 1),

                      _SwitchTile(
                        icon: Icons.location_on_outlined,
                        iconColor: const Color(0xFF10B981),
                        title: 'Share location automatically',
                        subtitle: 'Allow location sharing for active roadside help',
                        value: provider.autoShareLocationEnabled,
                        onChanged: provider.setAutoShareLocationEnabled,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),

                const _SectionTitle(
                  title: 'Support & legal',
                ),

                const SizedBox(
                  height: 8,
                ),

                _CardBox(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: const Color(0xFF10B981),
                        title: 'Privacy policy',
                        subtitle: 'Privacy, location and data use',
                        trailingIcon: Icons.chevron_right_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                              const PrivacyPolicyPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: TextButton.icon(
                    onPressed: _logout,
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
                    'App version 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: subtleTextColor,
                    ),
                  ),
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
  final Color textColor;
  final bool isVerified;

  const _Header({
    required this.textColor,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.10) : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isVerified ? Icons.verified_rounded : Icons.info_outline,
                size: 14,
                color: ProfilePage.primaryOrange,
              ),
              const SizedBox(width: 6),
              Text(
                isVerified ? 'Verified' : 'Pending',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final bool isDark;
  final Color textColor;
  final Color subtleTextColor;

  final VoidCallback onEdit;

  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.isDark,
    required this.textColor,
    required this.subtleTextColor,

    required this.onEdit,
  });

  String get initials {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

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
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
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
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: subtleTextColor,
                    ),
                  ),
                ],
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: subtleTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          Material(
            color:
            Colors.white
                .withOpacity(
              .95,
            ),
            borderRadius:
            BorderRadius.circular(
              999,
            ),
            child:
            InkWell(
              onTap:
              onEdit,
              borderRadius:
              BorderRadius.circular(
                999,
              ),
              child:
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal:
                  10,
                  vertical:
                  7,
                ),
                child:
                Row(
                  children: [
                    const Icon(
                      Icons
                          .edit_rounded,
                      size:
                      14,
                      color:
                      ProfilePage
                          .primaryOrange,
                    ),
                    const SizedBox(
                      width:
                      4,
                    ),
                    Text(
                      'Edit',
                      style:
                      theme
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                        color:
                        ProfilePage
                            .primaryOrange,
                        fontWeight:
                        FontWeight.w600,
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

class _CarCard extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isDark;

  const _CarCard({
    required this.vehicle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = vehicle.isPrimary;

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
              : (isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB)),
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
            vehicle.displayName.isEmpty ? 'Vehicle' : vehicle.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            vehicle.details.isEmpty ? 'No details' : vehicle.details,
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const _SectionTitle({
    required this.title,
    this.actionText,
    this.onActionTap
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
          InkWell(
            onTap: onActionTap,
            child: Text(
              actionText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ProfilePage.primaryOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _CardBox extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _CardBox({
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF020617) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB),
        ),
      ),
      child: child,
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
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor =
    isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          : trailingIcon != null
          ? Icon(
        trailingIcon,
        size: 18,
        color: isDark
            ? Colors.white.withOpacity(0.7)
            : const Color(0xFF9CA3AF),
      )
          : null,
      onTap: onTap,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
      onTap: onChanged == null
          ? null
          : () {
        onChanged!(!value);
      },
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
      child: Text(text),
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