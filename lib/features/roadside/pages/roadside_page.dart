import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/features/vehicles/data/models/vehicle_model.dart';

import '../data/models/roadside_model.dart';
import '../providers/roadside_provider.dart';
import '../../vehicles/providers/vehicle_provider.dart';

class RoadsidePage extends StatefulWidget {
  const RoadsidePage({super.key});

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);

  @override
  State<RoadsidePage> createState() => _RoadsidePageState();
}

class _RoadsidePageState extends State<RoadsidePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<RoadsideProvider>().loadHome();
      context.read<VehicleProvider>().loadVehicles();
    });
  }

  Future<Position?> _getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> _createRequestXXXXXXXXXX(RoadsideServiceModel service) async {
    final vehicleProvider = context.read<VehicleProvider>();
    final roadsideProvider = context.read<RoadsideProvider>();

    final vehicle = vehicleProvider.vehicles.firstWhere(
          (e) => e.isPrimary,
      orElse: () => vehicleProvider.vehicles.isNotEmpty
          ? vehicleProvider.vehicles.first
          : const VehicleModel(),
    );

    if (vehicle.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a car first.')),
      );
      return;
    }

    final position = await _getCurrentPosition();

    if (!mounted) return;

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required.')),
      );
      return;
    }

    final notesController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Describe your issue',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RoadsidePage.primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm request'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;

    final success = await roadsideProvider.createRequest(
      serviceId: service.id,
      vehicleId: vehicle.id!,
      latitude: position.latitude,
      longitude: position.longitude,
      notes: notesController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Roadside request created successfully.'
              : roadsideProvider.errorMessage ?? 'Failed to create request.',
        ),
      ),
    );
  }
  Future<void> _openRoadsideRequestSheet({
    RoadsideServiceModel? initialService,
  }) async {
    final roadside = context.read<RoadsideProvider>();
    final vehicleProvider = context.read<VehicleProvider>();

    if (roadside.services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No roadside services available.')),
      );
      return;
    }

    final vehicle = vehicleProvider.vehicles.firstWhere(
          (e) => e.isPrimary,
      orElse: () => vehicleProvider.vehicles.isNotEmpty
          ? vehicleProvider.vehicles.first
          : const VehicleModel(),
    );

    if (vehicle.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a car first.')),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _RoadsideRequestSheet(
          services: roadside.services,
          vehicleId: vehicle.id!,
          vehicleName: vehicle.displayName,
          initialService: initialService,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final roadside = context.watch<RoadsideProvider>();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : RoadsidePage.darkGrey;
    final subtleTextColor =
    isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);

    return SafeArea(
      child: Container(
        color: const Color(0xFFF3F4F6),
        child: RefreshIndicator(
          onRefresh: roadside.loadHome,
          child: roadside.isLoading && roadside.home == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  textColor: textColor,
                  subtleTextColor: subtleTextColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _LocationEtaCard(
                  isDark: isDark,
                  textColor: textColor,
                  subtleTextColor: subtleTextColor,
                  averageEta: roadside.averageEta,
                ),
                const SizedBox(height: 18),
                Center(
                  child: Column(
                    children: [
                      _BigRequestButton(
                        isLoading: roadside.isSubmitting,
                        onTap: roadside.services.isNotEmpty
                            ? () => _openRoadsideRequestSheet()
                            : null,
                      ),
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
                Text(
                  'What do you need help with?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                _ServicesGrid(
                  services: roadside.services,
                  onTap: (service) {
                    _openRoadsideRequestSheet(initialService: service);
                  },
                ),
                const SizedBox(height: 24),
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
                Text(
                  'Recent roadside requests',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                if (roadside.recentRequests.isEmpty)
                  _EmptyCard(isDark: isDark)
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: roadside.recentRequests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      return _RoadsideActivityTile(
                        request: roadside.recentRequests[index],
                        isDark: isDark,
                      );
                    },
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
  final Color subtleTextColor;
  final bool isDark;

  const _Header({
    required this.textColor,
    required this.subtleTextColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
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
              const Icon(Icons.location_on_rounded, size: 14),
              const SizedBox(width: 6),
              Text(
                'Current location',
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

class _LocationEtaCard extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color subtleTextColor;
  final String averageEta;

  const _LocationEtaCard({
    required this.isDark,
    required this.textColor,
    required this.subtleTextColor,
    required this.averageEta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF111827), Color(0xFF0F172A)]
              : const [Color(0xFFFFE0B2), Color(0xFFFFF3E0)],
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
              color: RoadsidePage.primaryOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Average arrival time in your area: $averageEta.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigRequestButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _BigRequestButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 210,
        height: 210,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [RoadsidePage.primaryOrange, Color(0xFFFF9800)],
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
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.electric_bolt_rounded, color: Colors.white, size: 40),
              SizedBox(height: 8),
              Text(
                'Request help now',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'We’ll match you in seconds',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  final List<RoadsideServiceModel> services;
  final void Function(RoadsideServiceModel service) onTap;

  const _ServicesGrid({
    required this.services,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Text('No roadside services available.');
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (_, index) {
        final service = services[index];

        return _IssueCard(
          icon: _iconFromKey(service.icon ?? service.slug ?? ''),
          label: service.name,
          desc: service.estimatedEta ?? '',
          onTap: () => onTap(service),
        );
      },
    );
  }

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'tow':
      case 'tow-truck':
        return Icons.local_shipping_rounded;
      case 'tire':
      case 'flat-tire':
        return Icons.tire_repair_rounded;
      case 'battery':
      case 'dead-battery':
        return Icons.car_crash_rounded;
      case 'lock':
      case 'locked-out':
        return Icons.lock_rounded;
      case 'fuel':
      case 'out-of-gas':
        return Icons.local_gas_station_rounded;
      default:
        return Icons.route_rounded;
    }
  }
}

class _IssueCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final VoidCallback onTap;

  const _IssueCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF020617) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: RoadsidePage.primaryOrange),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadsideActivityTile extends StatelessWidget {
  final RoadsideRequestModel request;
  final bool isDark;

  const _RoadsideActivityTile({
    required this.request,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.electric_bolt_rounded, color: statusColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              request.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              request.status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'requested':
        return const Color(0xFFF59E0B);
      case 'accepted':
      case 'on_the_way':
        return const Color(0xFF2563EB);
      case 'cancelled':
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return RoadsidePage.primaryOrange;
    }
  }
}

class _EmptyCard extends StatelessWidget {
  final bool isDark;

  const _EmptyCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text('No recent roadside requests yet.'),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF020617) : const Color(0xFFF9FAFB),
      ),
      child: Column(
        children: const [
          _HowStep(number: 1, title: 'Tell us what happened'),
          SizedBox(height: 10),
          _HowStep(number: 2, title: 'We match a nearby pro'),
          SizedBox(height: 10),
          _HowStep(number: 3, title: 'Track in real time'),
        ],
      ),
    );
  }
}

class _HowStep extends StatelessWidget {
  final int number;
  final String title;

  const _HowStep({
    required this.number,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: RoadsidePage.primaryOrange.withOpacity(0.12),
          child: Text(
            '$number',
            style: const TextStyle(
              color: RoadsidePage.primaryOrange,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title)),
      ],
    );
  }
}


class _RoadsideRequestSheet extends StatefulWidget {
  final List<RoadsideServiceModel> services;
  final int vehicleId;
  final String vehicleName;
  final RoadsideServiceModel? initialService;

  const _RoadsideRequestSheet({
    required this.services,
    required this.vehicleId,
    required this.vehicleName,
    this.initialService,
  });

  @override
  State<_RoadsideRequestSheet> createState() => _RoadsideRequestSheetState();
}

class _RoadsideRequestSheetState extends State<_RoadsideRequestSheet> {
  RoadsideServiceModel? selectedService;
  RoadsideVendorModel? selectedVendor;

  final notesController = TextEditingController();

  Position? currentPosition;
  bool isGettingLocation = false;

  @override
  void initState() {
    super.initState();

    selectedService = widget.initialService ?? widget.services.first;

    Future.microtask(loadVendorsForSelectedService);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<Position?> _getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> loadVendorsForSelectedService() async {
    if (selectedService?.id == null) return;

    setState(() {
      isGettingLocation = true;
      selectedVendor = null;
    });

    final position = await _getCurrentPosition();

    if (!mounted) return;

    setState(() {
      isGettingLocation = false;
      currentPosition = position;
    });

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required.')),
      );
      return;
    }

    await context.read<RoadsideProvider>().loadNearbyVendors(
      roadsideServiceId: selectedService!.id!,
      lat: position.latitude,
      lng: position.longitude,
    );
  }

  Future<void> submit() async {
    if (selectedService?.id == null) return;

    var position = currentPosition ?? await _getCurrentPosition();

    if (!mounted) return;

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required.')),
      );
      return;
    }

    final provider = context.read<RoadsideProvider>();

    final success = await provider.createRequest(
      serviceId: selectedService!.id!,
      vehicleId: widget.vehicleId,
      branchId: selectedVendor?.id,
      latitude: position.latitude,
      longitude: position.longitude,
      notes: notesController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Roadside request created successfully.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to create request.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadsideProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Request roadside help',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _RoadsideInfoBox(
                icon: Icons.directions_car_filled_rounded,
                title: widget.vehicleName.isEmpty
                    ? 'Your vehicle'
                    : widget.vehicleName,
                subtitle: 'Selected vehicle',
              ),

              const SizedBox(height: 16),

              const Text(
                '1. Choose service',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.services.map((service) {
                  final selected = selectedService?.id == service.id;

                  return ChoiceChip(
                    selected: selected,
                    label: Text(service.name),
                    selectedColor:
                    RoadsidePage.primaryOrange.withOpacity(0.18),
                    onSelected: (_) async {
                      setState(() {
                        selectedService = service;
                        selectedVendor = null;
                      });

                      await loadVendorsForSelectedService();
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '2. Nearby providers',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (isGettingLocation || provider.isLoadingVendors)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              if (isGettingLocation)
                const _RoadsideSmallMessage(
                  text: 'Getting your current location...',
                )
              else if (provider.isLoadingVendors)
                const _RoadsideSmallMessage(
                  text: 'Searching nearby roadside providers...',
                )
              else if (provider.nearbyVendors.isEmpty)
                  const _RoadsideSmallMessage(
                    text:
                    'No nearby providers found. You can still create a general request.',
                  )
                else ...[
                    _SkipVendorCard(
                      selected: selectedVendor == null,
                      onTap: () {
                        setState(() => selectedVendor = null);
                      },
                    ),
                    const SizedBox(height: 8),
                    ...provider.nearbyVendors.map((vendor) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _RoadsideVendorCard(
                          vendor: vendor,
                          selected: selectedVendor?.id == vendor.id,
                          onTap: () {
                            setState(() => selectedVendor = vendor);
                          },
                        ),
                      );
                    }),
                  ],

              const SizedBox(height: 16),

              TextField(
                controller: notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Example: Flat tire on highway shoulder',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: provider.isSubmitting ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RoadsidePage.primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  icon: provider.isSubmitting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.electric_bolt_rounded),
                  label: Text(
                    selectedVendor == null
                        ? 'Create general request'
                        : 'Request selected provider',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _RoadsideInfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _RoadsideInfoBox({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: RoadsidePage.primaryOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '-' : title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
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

class _RoadsideSmallMessage extends StatelessWidget {
  final String text;

  const _RoadsideSmallMessage({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 13,
        ),
      ),
    );
  }
}

class _SkipVendorCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _SkipVendorCard({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? RoadsidePage.primaryOrange.withOpacity(0.10)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? RoadsidePage.primaryOrange
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? RoadsidePage.primaryOrange
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Let any nearby provider accept',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadsideVendorCard extends StatelessWidget {
  final RoadsideVendorModel vendor;
  final bool selected;
  final VoidCallback onTap;

  const _RoadsideVendorCard({
    required this.vendor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price = vendor.basePrice == null
        ? '-'
        : '\$${vendor.basePrice!.toStringAsFixed(2)}';

    return Material(
      color: selected
          ? RoadsidePage.primaryOrange.withOpacity(0.10)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? RoadsidePage.primaryOrange
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? RoadsidePage.primaryOrange
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.branchName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vendor.vendorName ?? '',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          (vendor.rating ?? 0).toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${vendor.reviewsCount})',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${vendor.distanceMiles?.toStringAsFixed(1) ?? '-'} mi',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vendor.address ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _VendorMiniChip(
                          icon: Icons.schedule_rounded,
                          text: vendor.estimatedEta ?? '-',
                        ),
                        const SizedBox(width: 6),
                        _VendorMiniChip(
                          icon: Icons.attach_money_rounded,
                          text: price,
                        ),
                      ],
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

class _VendorMiniChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _VendorMiniChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: RoadsidePage.primaryOrange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: RoadsidePage.primaryOrange,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: RoadsidePage.primaryOrange,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}