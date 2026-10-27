import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/features/vehicles/data/models/vehicle_model.dart';

import '../../location/pages/location_picker_page.dart';
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
  Position? _currentPosition;

  RoadsideServiceModel? _nearbyService;
  RoadsideVendorModel? _selectedNearbyVendor;

  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(
      _loadPage,
    );
  }

  Future<void> _loadPage() async {
    final roadside =
    context.read<RoadsideProvider>();

    final vehicles =
    context.read<VehicleProvider>();

    await Future.wait([
      roadside.loadHome(),
      vehicles.loadVehicles(),
    ]);

    if (!mounted) return;

    await _loadCurrentLocation();

    if (!mounted) return;

    final tow =
    _findTowService(
      roadside.services,
    );

    if (tow != null) {
      setState(() {
        _nearbyService = tow;
      });

      await _loadNearbyProviders(
        tow,
      );
    }
  }

  Future<void>
  _loadCurrentLocation() async {
    if (_gettingLocation) {
      return;
    }

    setState(() {
      _gettingLocation = true;
    });

    final position =
    await _getCurrentPosition();

    if (!mounted) return;

    setState(() {
      _currentPosition =
          position;

      _gettingLocation = false;
    });
  }

  RoadsideServiceModel?
  _findTowService(
      List<RoadsideServiceModel>
      services,
      ) {
    for (final service
    in services) {
      final key = [
        service.slug ?? '',
        service.icon ?? '',
        service.name,
      ].join(' ').toLowerCase();

      if (key.contains('tow')) {
        return service;
      }
    }

    return null;
  }

  bool _isTowService(
      RoadsideServiceModel service,
      ) {
    final key = [
      service.slug ?? '',
      service.icon ?? '',
      service.name,
    ].join(' ').toLowerCase();

    return key.contains('tow');
  }

  Future<void>
  _loadNearbyProviders(
      RoadsideServiceModel service,
      ) async {
    if (service.id == null) {
      return;
    }

    var position =
        _currentPosition;

    if (position == null) {
      await _loadCurrentLocation();

      if (!mounted) return;

      position =
          _currentPosition;
    }

    if (position == null) {
      return;
    }

    setState(() {
      _nearbyService =
          service;

      _selectedNearbyVendor =
      null;
    });

    await context
        .read<RoadsideProvider>()
        .loadNearbyVendors(
      roadsideServiceId:
      service.id!,
      lat:
      position.latitude,
      lng:
      position.longitude,
    );
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

  Future<void>
  _openRoadsideRequestSheet({
    RoadsideServiceModel?
    initialService,

    RoadsideVendorModel?
    initialVendor,
  }) async {
    final roadside =
    context.read<
        RoadsideProvider>();

    final vehicleProvider =
    context.read<
        VehicleProvider>();

    if (roadside.services.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'No roadside services available.',
          ),
        ),
      );

      return;
    }

    final vehicle =
    vehicleProvider.vehicles
        .firstWhere(
          (e) => e.isPrimary,
      orElse: () =>
      vehicleProvider
          .vehicles
          .isNotEmpty
          ? vehicleProvider
          .vehicles.first
          : const VehicleModel(),
    );

    if (vehicle.id == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please add a car first.',
          ),
        ),
      );

      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      builder: (_) {
        return _RoadsideRequestSheet(
          services:
          roadside.services,
          vehicleId:
          vehicle.id!,
          vehicleName:
          vehicle.displayName,
          initialService:
          initialService,
          initialVendor:
          initialVendor,
        );
      },
    );

    if (!mounted) return;

    await roadside.loadHome();

    final nearbyService =
        _nearbyService;

    if (nearbyService != null) {
      await _loadNearbyProviders(
        nearbyService,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final roadside =
    context.watch<
        RoadsideProvider>();

    final vehicleProvider =
    context.watch<
        VehicleProvider>();

    final isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    final primaryVehicle =
        vehicleProvider.vehicles
            .where(
              (vehicle) =>
          vehicle.isPrimary,
        )
            .firstOrNull;

    final vehicle =
        primaryVehicle ??
            (vehicleProvider
                .vehicles
                .isNotEmpty
                ? vehicleProvider
                .vehicles.first
                : null);

    final active =
        roadside.activeRequest;

    return Material(
      color: isDark
          ? const Color(
        0xFF0B0F16,
      )
          : const Color(
        0xFFF5F6F8,
      ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color:
          RoadsidePage
              .primaryOrange,
          onRefresh:
          _loadPage,
          child:
          roadside.isLoading &&
              roadside.home ==
                  null
              ? const Center(
            child:
            CircularProgressIndicator(
              color:
              RoadsidePage
                  .primaryOrange,
            ),
          )
              : SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.only(
              bottom: 28,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                _RoadsideHero(
                  vehicleName:
                  vehicle
                      ?.displayName ??
                      'No vehicle selected',
                  hasLocation:
                  _currentPosition !=
                      null,
                  isLocating:
                  _gettingLocation,
                  onLocationTap:
                  _loadCurrentLocation,
                ),

                if (active !=
                    null) ...[
                  const SizedBox(
                    height: 16,
                  ),

                  Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal:
                      16,
                    ),
                    child:
                    _ActiveRoadsideCard(
                      request:
                      active,
                      onRefresh:
                      roadside.loadHome,
                    ),
                  ),
                ],

                const SizedBox(
                  height: 18,
                ),

                Padding(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal:
                    16,
                  ),
                  child:
                  _TowActionCard(
                    service:
                    _findTowService(
                      roadside.services,
                    ),
                    isDark:
                    isDark,
                    onTap:
                        (service) {
                      _openRoadsideRequestSheet(
                        initialService:
                        service,
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                Padding(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal:
                    16,
                  ),
                  child:
                  _RoadsideSectionHeader(
                    title:
                    'Quick roadside help',
                    subtitle:
                    'Choose what happened and get help fast',
                    isDark:
                    isDark,
                  ),
                ),

                const SizedBox(
                  height: 11,
                ),

                _QuickRoadsideServices(
                  services:
                  roadside.services,
                  isDark:
                  isDark,
                  onTap:
                      (service) {
                    _openRoadsideRequestSheet(
                      initialService:
                      service,
                    );
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                Padding(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal:
                    16,
                  ),
                  child:
                  _RoadsideSectionHeader(
                    title:
                    'Nearby help',
                    subtitle:
                    _nearbyService ==
                        null
                        ? 'Select a service to see nearby providers'
                        : 'Nearby providers for ${_nearbyService!.name}',
                    isDark:
                    isDark,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                _NearbyServiceSelector(
                  services:
                  roadside.services,
                  selectedService:
                  _nearbyService,
                  isDark:
                  isDark,
                  onTap:
                  _loadNearbyProviders,
                ),

                const SizedBox(
                  height: 11,
                ),

                Padding(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal:
                    16,
                  ),
                  child:
                  _RoadsideProviderMap(
                    isDark:
                    isDark,
                    currentPosition:
                    _currentPosition,
                    vendors:
                    roadside
                        .nearbyVendors,
                    selectedVendor:
                    _selectedNearbyVendor,
                    isLoading:
                    roadside
                        .isLoadingVendors,
                    onVendorSelected:
                        (vendor) {
                      setState(() {
                        _selectedNearbyVendor =
                            vendor;
                      });
                    },
                    onRequest:
                        (vendor) {
                      final service =
                          _nearbyService;

                      if (service ==
                          null) {
                        return;
                      }

                      _openRoadsideRequestSheet(
                        initialService:
                        service,
                        initialVendor:
                        vendor,
                      );
                    },
                  ),
                ),

                if (roadside
                    .recentRequests
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 24,
                  ),

                  Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal:
                      16,
                    ),
                    child:
                    _RoadsideSectionHeader(
                      title:
                      'Recent assistance',
                      subtitle:
                      'Your latest roadside requests',
                      isDark:
                      isDark,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ListView.separated(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal:
                      16,
                    ),
                    physics:
                    const NeverScrollableScrollPhysics(),
                    shrinkWrap:
                    true,
                    itemCount:
                    roadside
                        .recentRequests
                        .length,
                    separatorBuilder:
                        (_, __) =>
                    const SizedBox(
                      height: 8,
                    ),
                    itemBuilder:
                        (
                        context,
                        index,
                        ) {
                      return _RoadsideActivityTile(
                        request:
                        roadside
                            .recentRequests[
                        index],
                        isDark:
                        isDark,
                      );
                    },
                  ),
                ],
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


class _RoadsideRequestSheet
    extends StatefulWidget {
  final List<RoadsideServiceModel>
  services;

  final int vehicleId;
  final String vehicleName;

  final RoadsideServiceModel?
  initialService;

  final RoadsideVendorModel?
  initialVendor;

  const _RoadsideRequestSheet({
    required this.services,
    required this.vehicleId,
    required this.vehicleName,
    this.initialService,
    this.initialVendor,
  });

  @override
  State<_RoadsideRequestSheet>
  createState() =>
      _RoadsideRequestSheetState();
}

class _RoadsideRequestSheetState extends State<_RoadsideRequestSheet> {
  RoadsideServiceModel? selectedService;
  RoadsideVendorModel? selectedVendor;

  final notesController = TextEditingController();

  Position? currentPosition;
  bool isGettingLocation = false;


  bool get _isTowingService {
    final service =
        selectedService;

    if (service == null) {
      return false;
    }

    final key = [
      service.slug ?? '',
      service.name,
    ].join(' ').toLowerCase();

    return key.contains('tow');
  }
  LatLng? destinationPoint;
  String? destinationAddress;

  Future<void>
  _pickTowDestination() async {
    final result =
    await Navigator.of(context)
        .push<LocationSelection>(
      MaterialPageRoute(
        builder: (_) =>
            LocationPickerPage(
              initialPoint:
              destinationPoint,
              initialAddress:
              destinationAddress ??
                  '',
            ),
      ),
    );

    if (result == null ||
        !mounted) {
      return;
    }

    setState(() {
      destinationPoint =
          result.point;

      destinationAddress =
          result.address;
    });
  }

  @override
  void initState() {
    super.initState();

    selectedService =
        widget.initialService ??
            widget.services.first;

    selectedVendor =
        widget.initialVendor;

    Future.microtask(
      loadVendorsForSelectedService,
    );
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

  Future<void>
  loadVendorsForSelectedService()
  async {
    if (selectedService?.id ==
        null) {
      return;
    }

    final preferredVendorId =
        selectedVendor?.id ??
            widget.initialVendor?.id;

    setState(() {
      isGettingLocation =
      true;
    });

    final position =
        currentPosition ??
            await _getCurrentPosition();

    if (!mounted) return;

    setState(() {
      isGettingLocation =
      false;

      currentPosition =
          position;
    });

    if (position == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission is required.',
          ),
        ),
      );

      return;
    }

    final provider =
    context.read<
        RoadsideProvider>();

    await provider
        .loadNearbyVendors(
      roadsideServiceId:
      selectedService!.id!,
      lat:
      position.latitude,
      lng:
      position.longitude,
    );

    if (!mounted) return;

    if (preferredVendorId !=
        null) {
      RoadsideVendorModel? found;

      for (final vendor
      in provider
          .nearbyVendors) {
        if (vendor.id ==
            preferredVendorId) {
          found = vendor;
          break;
        }
      }

      if (found != null) {
        setState(() {
          selectedVendor =
              found;
        });
      }
    }
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

    if (_isTowingService &&
        destinationPoint == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please choose where the vehicle should be towed.',
          ),
        ),
      );

      return;
    }


    final provider = context.read<RoadsideProvider>();


    final success =
    await provider.createRequest(
      serviceId:
      selectedService!.id!,

      vehicleId:
      widget.vehicleId,

      branchId:
      selectedVendor?.id,

      latitude:
      position.latitude,

      longitude:
      position.longitude,

      destinationAddress:
      _isTowingService
          ? destinationAddress
          : null,

      destinationLatitude:
      _isTowingService
          ? destinationPoint
          ?.latitude
          : null,

      destinationLongitude:
      _isTowingService
          ? destinationPoint
          ?.longitude
          : null,

      notes:
      notesController.text
          .trim(),
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
                    /*onSelected: (_) async {
                      setState(() {
                        selectedService = service;
                        selectedVendor = null;
                      });

                      await loadVendorsForSelectedService();
                    },*/
                    onSelected: (_) async {
                      setState(() {
                        selectedService =
                            service;

                        selectedVendor =
                        null;

                        if (!_isTowingService) {
                          destinationPoint =
                          null;

                          destinationAddress =
                          null;
                        }
                      });

                      await loadVendorsForSelectedService();
                    },

                  );
                }).toList(),
              ),
              if (_isTowingService) ...[
                const SizedBox(
                  height: 16,
                ),

                const Text(
                  '2. Tow destination',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                Material(
                  color:
                  const Color(
                    0xFFFFF7EF,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                  child: InkWell(
                    onTap:
                    _pickTowDestination,
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                    child: Container(
                      width:
                      double.infinity,
                      padding:
                      const EdgeInsets.all(
                        13,
                      ),
                      decoration:
                      BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                        border: Border.all(
                          color: RoadsidePage
                              .primaryOrange
                              .withOpacity(
                            .20,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration:
                            BoxDecoration(
                              color: RoadsidePage
                                  .primaryOrange
                                  .withOpacity(
                                .10,
                              ),
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                            child:
                            const Icon(
                              Icons
                                  .flag_rounded,
                              color:
                              RoadsidePage
                                  .primaryOrange,
                              size: 19,
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
                                  destinationPoint ==
                                      null
                                      ? 'Where should we tow your car?'
                                      : 'Tow destination',
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .w700,
                                    fontSize: 11,
                                  ),
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                Text(
                                  destinationAddress ??
                                      'Choose the destination on the map',
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                  style:
                                  const TextStyle(
                                    color:
                                    Color(
                                      0xFF7E8691,
                                    ),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Icon(
                            destinationPoint ==
                                null
                                ? Icons
                                .map_outlined
                                : Icons
                                .check_circle_rounded,
                            color: RoadsidePage
                                .primaryOrange,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isTowingService
                          ? '3. Nearby towing providers'
                          : '2. Nearby providers',
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
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



























class _RoadsideHero
    extends StatelessWidget {
  final String vehicleName;
  final bool hasLocation;
  final bool isLocating;

  final VoidCallback
  onLocationTap;

  const _RoadsideHero({
    required this.vehicleName,
    required this.hasLocation,
    required this.isLocating,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        20,
      ),
      decoration:
      const BoxDecoration(
        gradient:
        LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            Color(
              0xFF172033,
            ),
            Color(
              0xFF202B3D,
            ),
          ],
        ),
        borderRadius:
        BorderRadius.vertical(
          bottom:
          Radius.circular(
            28,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color:
                  Colors.white
                      .withOpacity(
                    .08,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .emergency_rounded,
                  color:
                  RoadsidePage
                      .primaryOrange,
                  size: 22,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      'Roadside assistance',
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontSize:
                        18,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),

                    SizedBox(
                      height: 2,
                    ),

                    Text(
                      'Fast help when your vehicle can’t keep going',
                      style:
                      TextStyle(
                        color:
                        Color(
                          0xFFAAB2BE,
                        ),
                        fontSize:
                        9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 17,
          ),

          Row(
            children: [
              Expanded(
                child:
                _RoadsideHeroPill(
                  icon: Icons
                      .directions_car_filled_rounded,
                  title:
                  vehicleName,
                  subtitle:
                  'Vehicle',
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                Material(
                  color:
                  Colors.transparent,
                  child:
                  InkWell(
                    onTap:
                    onLocationTap,
                    borderRadius:
                    BorderRadius.circular(
                      13,
                    ),
                    child:
                    _RoadsideHeroPill(
                      icon: Icons
                          .my_location_rounded,
                      title: isLocating
                          ? 'Finding location...'
                          : hasLocation
                          ? 'Current location'
                          : 'Location needed',
                      subtitle: hasLocation
                          ? 'Ready for dispatch'
                          : 'Tap to locate',
                    ),
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


class _RoadsideHeroPill
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _RoadsideHeroPill({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
      const BoxConstraints(
        minHeight: 50,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white
            .withOpacity(
          .07,
        ),
        borderRadius:
        BorderRadius.circular(
          13,
        ),
        border:
        Border.all(
          color:
          Colors.white
              .withOpacity(
            .06,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color:
            RoadsidePage
                .primaryOrange,
          ),

          const SizedBox(
            width: 7,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              mainAxisAlignment:
              MainAxisAlignment
                  .center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 9.5,
                    fontWeight:
                    FontWeight
                        .w600,
                  ),
                ),

                const SizedBox(
                  height: 1,
                ),

                Text(
                  subtitle,
                  style:
                  TextStyle(
                    color: Colors
                        .white
                        .withOpacity(
                      .45,
                    ),
                    fontSize: 7.5,
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
class _TowActionCard
    extends StatelessWidget {
  final RoadsideServiceModel?
  service;

  final bool isDark;

  final ValueChanged<
      RoadsideServiceModel>
  onTap;

  const _TowActionCard({
    required this.service,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tow =
        service;

    return Container(
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        gradient:
        const LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            Color(
              0xFFF57C00,
            ),
            Color(
              0xFFFF9A32,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: RoadsidePage
                .primaryOrange
                .withOpacity(
              .20,
            ),
            blurRadius: 20,
            offset:
            const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Material(
        color:
        Colors.transparent,
        child: InkWell(
          onTap: tow == null
              ? null
              : () =>
              onTap(tow),
          borderRadius:
          BorderRadius.circular(
            20,
          ),
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              15,
              14,
              15,
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white
                        .withOpacity(
                      .16,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                  child:
                  const Icon(
                    Icons
                        .local_shipping_rounded,
                    color:
                    Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Text(
                        'Need a tow?',
                        style:
                        TextStyle(
                          color:
                          Colors.white,
                          fontSize:
                          17,
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      const Text(
                        'Get your vehicle picked up and transported safely.',
                        style:
                        TextStyle(
                          color:
                          Colors.white70,
                          fontSize:
                          9.5,
                          height:
                          1.35,
                        ),
                      ),

                      if (tow
                          ?.estimatedEta !=
                          null) ...[
                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          'Typical response: ${tow!.estimatedEta}',
                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                            fontSize:
                            8.5,
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Container(
                  width: 36,
                  height: 36,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      11,
                    ),
                  ),
                  child:
                  const Icon(
                    Icons
                        .arrow_forward_rounded,
                    color:
                    RoadsidePage
                        .primaryOrange,
                    size: 18,
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
class _QuickRoadsideServices
    extends StatelessWidget {
  final List<RoadsideServiceModel>
  services;

  final bool isDark;

  final ValueChanged<
      RoadsideServiceModel>
  onTap;

  const _QuickRoadsideServices({
    required this.services,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const SizedBox
          .shrink();
    }

    return SizedBox(
      height: 94,
      child:
      ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount:
        services.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(
          width: 9,
        ),
        itemBuilder:
            (
            context,
            index,
            ) {
          final service =
          services[index];

          return _QuickServiceCard(
            service:
            service,
            isDark:
            isDark,
            onTap:
                () => onTap(
              service,
            ),
          );
        },
      ),
    );
  }
}


class _QuickServiceCard
    extends StatelessWidget {
  final RoadsideServiceModel
  service;

  final bool isDark;
  final VoidCallback onTap;

  const _QuickServiceCard({
    required this.service,
    required this.isDark,
    required this.onTap,
  });

  IconData get icon {
    final key = [
      service.icon ?? '',
      service.slug ?? '',
      service.name,
    ].join(' ').toLowerCase();

    if (key.contains('tow')) {
      return Icons
          .local_shipping_rounded;
    }

    if (key.contains('tire')) {
      return Icons
          .tire_repair_rounded;
    }

    if (key.contains(
      'battery',
    )) {
      return Icons
          .battery_charging_full_rounded;
    }

    if (key.contains('fuel') ||
        key.contains('gas')) {
      return Icons
          .local_gas_station_rounded;
    }

    if (key.contains('lock')) {
      return Icons
          .lock_open_rounded;
    }

    return Icons
        .build_circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? const Color(
        0xFF151B25,
      )
          : Colors.white,
      borderRadius:
      BorderRadius.circular(
        16,
      ),
      child: InkWell(
        onTap:
        onTap,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        child: Container(
          width: 96,
          padding:
          const EdgeInsets.all(
            10,
          ),
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            border:
            Border.all(
              color: isDark
                  ? Colors.white
                  .withOpacity(
                .06,
              )
                  : const Color(
                0xFFE4E7EB,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration:
                BoxDecoration(
                  color: RoadsidePage
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
                  icon,
                  color:
                  RoadsidePage
                      .primaryOrange,
                  size: 18,
                ),
              ),

              const Spacer(),

              Text(
                service.name,
                maxLines: 1,
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
                  fontSize: 9.5,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              if (service
                  .estimatedEta !=
                  null)
                Text(
                  service
                      .estimatedEta!,
                  maxLines: 1,
                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF939AA4,
                    ),
                    fontSize: 7.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyServiceSelector
    extends StatelessWidget {
  final List<RoadsideServiceModel>
  services;

  final RoadsideServiceModel?
  selectedService;

  final bool isDark;

  final ValueChanged<
      RoadsideServiceModel>
  onTap;

  const _NearbyServiceSelector({
    required this.services,
    required this.selectedService,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child:
      ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount:
        services.length,
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
          final service =
          services[index];

          final selected =
              selectedService?.id ==
                  service.id;

          return Material(
            color: selected
                ? RoadsidePage
                .primaryOrange
                : isDark
                ? const Color(
              0xFF151B25,
            )
                : Colors.white,
            borderRadius:
            BorderRadius.circular(
              999,
            ),
            child: InkWell(
              onTap:
                  () => onTap(
                service,
              ),
              borderRadius:
              BorderRadius.circular(
                999,
              ),
              child: Container(
                alignment:
                Alignment.center,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 13,
                ),
                decoration:
                BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                    999,
                  ),
                  border:
                  Border.all(
                    color: selected
                        ? RoadsidePage
                        .primaryOrange
                        : isDark
                        ? Colors.white
                        .withOpacity(
                      .06,
                    )
                        : const Color(
                      0xFFE3E6EA,
                    ),
                  ),
                ),
                child: Text(
                  service.name,
                  style:
                  TextStyle(
                    color: selected
                        ? Colors.white
                        : isDark
                        ? Colors.white
                        : const Color(
                      0xFF555D68,
                    ),
                    fontSize: 9,
                    fontWeight:
                    selected
                        ? FontWeight
                        .w700
                        : FontWeight
                        .w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoadsideProviderMap
    extends StatelessWidget {
  final bool isDark;

  final Position?
  currentPosition;

  final List<RoadsideVendorModel>
  vendors;

  final RoadsideVendorModel?
  selectedVendor;

  final bool isLoading;

  final ValueChanged<
      RoadsideVendorModel>
  onVendorSelected;

  final ValueChanged<
      RoadsideVendorModel>
  onRequest;

  const _RoadsideProviderMap({
    required this.isDark,
    required this.currentPosition,
    required this.vendors,
    required this.selectedVendor,
    required this.isLoading,
    required this.onVendorSelected,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final mapped =
    vendors.where(
          (vendor) =>
      vendor.latitude != null &&
          vendor.longitude != null,
    ).toList();

    final userPoint =
    currentPosition == null
        ? null
        : LatLng(
      currentPosition!
          .latitude,
      currentPosition!
          .longitude,
    );

    LatLng? center =
        userPoint;

    if (center == null &&
        mapped.isNotEmpty) {
      center = LatLng(
        mapped.first.latitude!,
        mapped.first.longitude!,
      );
    }

    return Container(
      height: 290,
      decoration:
      BoxDecoration(
        color: isDark
            ? const Color(
          0xFF151B25,
        )
            : Colors.white,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border:
        Border.all(
          color: isDark
              ? Colors.white
              .withOpacity(
            .06,
          )
              : const Color(
            0xFFE3E6EA,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(
          19,
        ),
        child: center == null
            ? const Center(
          child: Text(
            'Location is required to show nearby help.',
          ),
        )
            : Stack(
          children: [
            Positioned.fill(
              child:
              FlutterMap(
                options:
                MapOptions(
                  initialCenter:
                  center,
                  initialZoom:
                  12,
                  minZoom:
                  3,
                  maxZoom:
                  18,
                ),
                children: [
                  ColorFiltered(
                    colorFilter:
                    ColorFilter
                        .mode(
                      isDark
                          ? const Color(
                        0xFF172033,
                      ).withOpacity(
                        .42,
                      )
                          : const Color(
                        0xFFFFF2E5,
                      ).withOpacity(
                        .15,
                      ),
                      isDark
                          ? BlendMode
                          .multiply
                          : BlendMode
                          .softLight,
                    ),
                    child:
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                      'com.koshy.koshy.talabatfresh',
                    ),
                  ),

                  MarkerLayer(
                    markers: [
                      if (userPoint !=
                          null)
                        Marker(
                          point:
                          userPoint,
                          width:
                          30,
                          height:
                          30,
                          child:
                          const _RoadsideUserMarker(),
                        ),

                      ...mapped.map(
                            (
                            vendor,
                            ) {
                          final selected =
                              selectedVendor?.id ==
                                  vendor.id;

                          return Marker(
                            point:
                            LatLng(
                              vendor
                                  .latitude!,
                              vendor
                                  .longitude!,
                            ),
                            width:
                            44,
                            height:
                            44,
                            child:
                            _RoadsideProviderMarker(
                              selected:
                              selected,
                              onTap:
                                  () {
                                onVendorSelected(
                                  vendor,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              left: 10,
              top: 10,
              child:
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal:
                  9,
                  vertical:
                  6,
                ),
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xE6172033,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    99,
                  ),
                ),
                child:
                Text(
                  isLoading
                      ? 'Searching nearby...'
                      : '${mapped.length} nearby provider${mapped.length == 1 ? '' : 's'}',
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize:
                    8.5,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ),

            if (selectedVendor !=
                null)
              Positioned(
                left: 10,
                right: 10,
                bottom: 18,
                child:
                _SelectedRoadsideProviderCard(
                  vendor:
                  selectedVendor!,
                  onRequest:
                      () {
                    onRequest(
                      selectedVendor!,
                    );
                  },
                ),
              ),

            const Positioned(
              bottom: 5,
              right: 7,
              child: Text(
                '© OpenStreetMap contributors',
                style:
                TextStyle(
                  fontSize:
                  6.5,
                  color:
                  Color(
                    0xFF69717C,
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

class _RoadsideUserMarker
    extends StatelessWidget {
  const _RoadsideUserMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFF3478F6,
        ),
        shape:
        BoxShape.circle,
        border:
        Border.all(
          color:
          Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color:
            const Color(
              0xFF3478F6,
            ).withOpacity(
              .30,
            ),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }
}


class _RoadsideProviderMarker
    extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _RoadsideProviderMarker({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
      onTap,
      child:
      AnimatedContainer(
        duration:
        const Duration(
          milliseconds:
          180,
        ),
        decoration:
        BoxDecoration(
          color: selected
              ? const Color(
            0xFF172033,
          )
              : RoadsidePage
              .primaryOrange,
          shape:
          BoxShape.circle,
          border:
          Border.all(
            color:
            Colors.white,
            width: selected
                ? 3
                : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black
                  .withOpacity(
                .18,
              ),
              blurRadius: 8,
              offset:
              const Offset(
                0,
                3,
              ),
            ),
          ],
        ),
        child:
        const Icon(
          Icons
              .local_shipping_rounded,
          size: 18,
          color:
          Colors.white,
        ),
      ),
    );
  }
}


class _SelectedRoadsideProviderCard
    extends StatelessWidget {
  final RoadsideVendorModel
  vendor;

  final VoidCallback onRequest;

  const _SelectedRoadsideProviderCard({
    required this.vendor,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final price =
    vendor.basePrice == null
        ? null
        : '\$${vendor.basePrice!.toStringAsFixed(2)}';

    return Container(
      padding:
      const EdgeInsets.all(
        10,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          15,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withOpacity(
              .14,
            ),
            blurRadius:
            18,
            offset:
            const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration:
            BoxDecoration(
              color: RoadsidePage
                  .primaryOrange
                  .withOpacity(
                .10,
              ),
              borderRadius:
              BorderRadius.circular(
                11,
              ),
            ),
            child:
            const Icon(
              Icons
                  .local_shipping_rounded,
              size: 18,
              color:
              RoadsidePage
                  .primaryOrange,
            ),
          ),

          const SizedBox(
            width: 9,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  vendor.branchName,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF172033,
                    ),
                    fontSize: 10.5,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Wrap(
                  spacing: 6,
                  children: [
                    Text(
                      '★ ${(vendor.rating ?? 0).toStringAsFixed(1)}',
                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF555D68,
                        ),
                        fontSize:
                        8.5,
                      ),
                    ),

                    if (vendor
                        .distanceMiles !=
                        null)
                      Text(
                        '${vendor.distanceMiles!.toStringAsFixed(1)} mi',
                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF777F8B,
                          ),
                          fontSize:
                          8.5,
                        ),
                      ),

                    if (vendor
                        .estimatedEta !=
                        null)
                      Text(
                        vendor
                            .estimatedEta!,
                        style:
                        const TextStyle(
                          color:
                          RoadsidePage
                              .primaryOrange,
                          fontSize:
                          8.5,
                          fontWeight:
                          FontWeight
                              .w600,
                        ),
                      ),

                    if (price !=
                        null)
                      Text(
                        'From $price',
                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF158764,
                          ),
                          fontSize:
                          8.5,
                          fontWeight:
                          FontWeight
                              .w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 6,
          ),

          SizedBox(
            height: 33,
            child:
            FilledButton(
              onPressed:
              onRequest,
              style:
              FilledButton
                  .styleFrom(
                backgroundColor:
                RoadsidePage
                    .primaryOrange,
                padding:
                const EdgeInsets.symmetric(
                  horizontal:
                  11,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),
              child:
              const Text(
                'Request',
                style:
                TextStyle(
                  fontSize:
                  8.5,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _ActiveRoadsideCard
    extends StatelessWidget {
  final RoadsideRequestModel
  request;

  final Future<void> Function()
  onRefresh;

  const _ActiveRoadsideCard({
    required this.request,
    required this.onRefresh,
  });

  String get statusLabel {
    switch (request.status) {
      case 'requested':
        return 'Finding help';

      case 'matched':
        return 'Provider matched';

      case 'accepted':
        return 'Request accepted';

      case 'on_the_way':
        return 'Help is on the way';

      case 'arrived':
        return 'Provider arrived';

      case 'in_progress':
        return 'Service in progress';

      default:
        return request.status;
    }
  }

  IconData get statusIcon {
    switch (request.status) {
      case 'on_the_way':
        return Icons
            .local_shipping_rounded;

      case 'arrived':
        return Icons
            .location_on_rounded;

      case 'in_progress':
        return Icons
            .build_circle_rounded;

      default:
        return Icons
            .radar_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFF172033,
        ),
        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration:
            BoxDecoration(
              color: RoadsidePage
                  .primaryOrange
                  .withOpacity(
                .14,
              ),
              shape:
              BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color:
              RoadsidePage
                  .primaryOrange,
              size: 21,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                const Text(
                  'Active roadside request',
                  style:
                  TextStyle(
                    color:
                    Color(
                      0xFFAEB5BF,
                    ),
                    fontSize: 8.5,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  request.title,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 11.5,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  statusLabel,
                  style:
                  const TextStyle(
                    color:
                    RoadsidePage
                        .primaryOrange,
                    fontSize: 9,
                    fontWeight:
                    FontWeight
                        .w600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed:
                () {
              onRefresh();
            },
            icon:
            const Icon(
              Icons
                  .refresh_rounded,
              color:
              Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}


class _RoadsideSectionHeader
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _RoadsideSectionHeader({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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

        const SizedBox(
          height: 2,
        ),

        Text(
          subtitle,
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
    );
  }
}


