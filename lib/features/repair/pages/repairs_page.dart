import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/features/vehicles/data/models/vehicle_model.dart';

import '../data/models/repair_model.dart';
import '../providers/repair_provider.dart';

class RepairsPage extends StatefulWidget {
  const RepairsPage({super.key});

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);

  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final position = await _getCurrentPosition();

      if (!mounted) return;

      context.read<RepairProvider>().loadHome(
        lat: position?.latitude,
        lng: position?.longitude,
        radius: 10,
      );
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

  Future<void> _search(String value) async {
    final position = await _getCurrentPosition();

    if (!mounted) return;

    context.read<RepairProvider>().loadWorkshops(
      lat: position?.latitude,
      lng: position?.longitude,
      radius: 10,
      search: value,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repair = context.watch<RepairProvider>();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : RepairsPage.darkGrey;
    final subtleTextColor =
    isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);

    return SafeArea(
      child: Container(
        color: const Color(0xFFF3F4F6),
        child: RefreshIndicator(
          onRefresh: () async {
            final position = await _getCurrentPosition();
            if (!mounted) return;

            await context.read<RepairProvider>().loadHome(
              lat: position?.latitude,
              lng: position?.longitude,
              radius: 10,
            );
          },
          child: repair.isLoading && repair.home == null
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
                  vehicleName:
                  repair.home?.primaryVehicle?.displayName ?? 'Your car',
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _search,
                  decoration: InputDecoration(
                    hintText:
                    'Search shops or services (e.g. “oil change”)',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        _search('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    )
                        : null,
                    filled: true,
                    fillColor:
                    isDark ? const Color(0xFF020617) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Popular services',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 10),

                _ServicesRow(
                  services: repair.popularServices,
                  selectedService: repair.selectedService,
                  onTap: (service) async {
                    await repair.selectService(service);

                    final position = await _getCurrentPosition();

                    if (!mounted) return;

                    repair.loadWorkshops(
                      serviceId: service.id,
                      serviceType: service.serviceType ?? 'repair',
                      lat: position?.latitude,
                      lng: position?.longitude,
                      radius: 10,
                    );
                  },
                ),

                const SizedBox(height: 20),

                _MapPreviewCard(isDark: isDark),

                const SizedBox(height: 20),

                _WorkshopSection(
                  title: 'Workshops – repair & maintenance',
                  subtitle: 'Mechanical, electrical and general service workshops.',
                  workshops: repair.repairWorkshops,
                  isDark: isDark,
                  textColor: textColor,
                  subtleTextColor: subtleTextColor,
                  onBook: _openRepairRequestSheet,
                ),

                const SizedBox(height: 24),

                _WorkshopSection(
                  title: 'Body repair (سمكرة) workshops',
                  subtitle: 'Paint, dents, body work and accident repair specialists.',
                  workshops: repair.bodyRepairWorkshops,
                  isDark: isDark,
                  textColor: textColor,
                  subtleTextColor: subtleTextColor,
                  onBook: _openRepairRequestSheet,
                ),

                const SizedBox(height: 24),

                if (repair.recentRequests.isNotEmpty) ...[
                  Text(
                    'Recent repair requests',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: repair.recentRequests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      return _RepairRequestTile(
                        request: repair.recentRequests[index],
                        isDark: isDark,
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

  Future<void> _openRepairRequestSheet(RepairWorkshopModel workshop) async {
    final repair = context.read<RepairProvider>();

    final vehicle = repair.home?.primaryVehicle;

    if (vehicle?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a car first.'),
        ),
      );
      return;
    }

    final selectedService = repair.selectedService;

    if (selectedService?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service first.'),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _RepairRequestSheet(
          workshop: workshop,
          vehicle: vehicle!,
          service: selectedService!,
        );
      },
    );

    if (result == true && mounted) {
      await context.read<RepairProvider>().loadRequests();
    }
  }
}

class _Header extends StatelessWidget {
  final Color textColor;
  final Color subtleTextColor;
  final bool isDark;
  final String vehicleName;

  const _Header({
    required this.textColor,
    required this.subtleTextColor,
    required this.isDark,
    required this.vehicleName,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded, size: 14),
                  SizedBox(width: 6),
                  Text('Current location'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              vehicleName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: subtleTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ServicesRow extends StatelessWidget {
  final List<RepairServiceModel> services;
  final RepairServiceModel? selectedService;
  final void Function(RepairServiceModel service) onTap;

  const _ServicesRow({
    required this.services,
    required this.selectedService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Text('No services available.');
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final service = services[index];

          return _ServiceChip(
            label: service.name,
            icon: _serviceIcon(service.slug ?? service.name),
            selected: selectedService?.id == service.id,
            onTap: () => onTap(service),
          );
        },
      ),
    );
  }

  IconData _serviceIcon(String key) {
    final lower = key.toLowerCase();

    if (lower.contains('oil')) return Icons.oil_barrel_rounded;
    if (lower.contains('diagnostic')) return Icons.device_unknown_rounded;
    if (lower.contains('brake')) return Icons.stop_circle_rounded;
    if (lower.contains('tire')) return Icons.tire_repair_rounded;
    if (lower.contains('a/c') || lower.contains('ac')) {
      return Icons.ac_unit_rounded;
    }

    return Icons.build_rounded;
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? RepairsPage.primaryOrange.withOpacity(0.16)
        : const Color(0xFFF3F4F6);

    final color = selected ? RepairsPage.primaryOrange : const Color(0xFF374151);

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
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkshopSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<RepairWorkshopModel> workshops;
  final bool isDark;
  final Color textColor;
  final Color subtleTextColor;
  final void Function(RepairWorkshopModel workshop) onBook;

  const _WorkshopSection({
    required this.title,
    required this.subtitle,
    required this.workshops,
    required this.isDark,
    required this.textColor,
    required this.subtleTextColor,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Text(
              'View all',
              style: theme.textTheme.bodySmall?.copyWith(
                color: RepairsPage.primaryOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: subtleTextColor,
          ),
        ),
        const SizedBox(height: 10),
        if (workshops.isEmpty)
          _EmptyCard(
            text: 'No workshops available yet.',
            isDark: isDark,
          )
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: workshops.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              return _ShopCard(
                workshop: workshops[index],
                isDark: isDark,
                onBook: () => onBook(workshops[index]),
              );
            },
          ),
      ],
    );
  }
}

class _ShopCard extends StatelessWidget {
  final RepairWorkshopModel workshop;
  final bool isDark;
  final VoidCallback onBook;

  const _ShopCard({
    required this.workshop,
    required this.isDark,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF020617) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: RepairsPage.primaryOrange.withOpacity(0.10),
            ),
            child: const Icon(
              Icons.home_repair_service_rounded,
              color: RepairsPage.primaryOrange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workshop.branchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${workshop.distanceMiles?.toStringAsFixed(1) ?? '-'} mi • ${workshop.address ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 3),
                    Text(
                      (workshop.rating ?? 0).toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${workshop.reviewsCount})',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if ((workshop.tag ?? '').isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: const Color(0xFF10B981).withOpacity(0.10),
                        ),
                        child: Text(
                          workshop.tag!,
                          style: const TextStyle(
                            color: Color(0xFF047857),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  workshop.servicesText ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Next available: ${workshop.nextAvailableSlot ?? '-'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    InkWell(
                      onTap: onBook,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: RepairsPage.primaryOrange.withOpacity(0.10),
                        ),
                        child: const Text(
                          'Book',
                          style: TextStyle(
                            color: RepairsPage.primaryOrange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
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

class _RepairRequestTile extends StatelessWidget {
  final RepairRequestModel request;
  final bool isDark;

  const _RepairRequestTile({
    required this.request,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.build_circle_rounded, color: color),
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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              request.status,
              style: TextStyle(
                color: color,
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
      case 'confirmed':
      case 'quoted':
      case 'in_progress':
        return const Color(0xFF2563EB);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return RepairsPage.primaryOrange;
    }
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF020617) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text),
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


class _RepairRequestSheet extends StatefulWidget {
  final RepairWorkshopModel workshop;
  final VehicleModel vehicle;
  final RepairServiceModel service;

  const _RepairRequestSheet({
    required this.workshop,
    required this.vehicle,
    required this.service,
  });

  @override
  State<_RepairRequestSheet> createState() => _RepairRequestSheetState();
}

class _RepairRequestSheetState extends State<_RepairRequestSheet> {
  final formKey = GlobalKey<FormState>();

  final issueTitleController = TextEditingController();
  final issueDescriptionController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool pickupRequired = false;

  @override
  void initState() {
    super.initState();

    issueTitleController.text = widget.service.name;
  }

  @override
  void dispose() {
    issueTitleController.dispose();
    issueDescriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (result != null) {
      setState(() => selectedDate = result);
    }
  }

  Future<void> pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (result != null) {
      setState(() => selectedTime = result);
    }
  }

  String? get formattedDate {
    if (selectedDate == null) return null;

    final y = selectedDate!.year.toString().padLeft(4, '0');
    final m = selectedDate!.month.toString().padLeft(2, '0');
    final d = selectedDate!.day.toString().padLeft(2, '0');

    return '$y-$m-$d';
  }

  String? get formattedTime {
    if (selectedTime == null) return null;

    final h = selectedTime!.hour.toString().padLeft(2, '0');
    final m = selectedTime!.minute.toString().padLeft(2, '0');

    return '$h:$m';
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    if (widget.workshop.id == null ||
        widget.vehicle.id == null ||
        widget.service.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing booking data.'),
        ),
      );
      return;
    }

    final provider = context.read<RepairProvider>();

    final success = await provider.createRepairRequest(
      vehicleId: widget.vehicle.id!,
      branchId: widget.workshop.id!,
      serviceId: widget.service.id!,
      issueTitle: issueTitleController.text.trim(),
      issueDescription: issueDescriptionController.text.trim(),
      preferredDate: formattedDate,
      preferredTime: formattedTime,
      pickupRequired: pickupRequired,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Repair request created successfully.'),
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
    final provider = context.watch<RepairProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.55,
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
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Form(
            key: formKey,
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
                  'Book repair service',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                _InfoBox(
                  icon: Icons.home_repair_service_rounded,
                  title: widget.workshop.branchName,
                  subtitle: widget.workshop.address ?? 'Workshop',
                ),

                const SizedBox(height: 10),

                _InfoBox(
                  icon: Icons.directions_car_filled_rounded,
                  title: widget.vehicle.displayName,
                  subtitle: widget.vehicle.details,
                ),

                const SizedBox(height: 10),

                _InfoBox(
                  icon: Icons.build_circle_rounded,
                  title: widget.service.name,
                  subtitle: widget.service.description ?? 'Selected service',
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: issueTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Issue title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter issue title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: issueDescriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Issue description',
                    hintText: 'Describe what is wrong with the car',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pickDate,
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: Text(
                          formattedDate ?? 'Select date',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pickTime,
                        icon: const Icon(Icons.schedule_rounded),
                        label: Text(
                          formattedTime ?? 'Select time',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                SwitchListTile(
                  value: pickupRequired,
                  onChanged: (value) {
                    setState(() => pickupRequired = value);
                  },
                  title: const Text('Pickup required'),
                  subtitle: const Text('Workshop will pick up the vehicle'),
                  activeColor: RepairsPage.primaryOrange,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 18),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: provider.isSubmitting ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RepairsPage.primaryOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: provider.isSubmitting
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Create repair request'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _InfoBox({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: RepairsPage.primaryOrange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '-' : title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((subtitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
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