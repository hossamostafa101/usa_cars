import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/features/vehicles/data/models/vehicle_model.dart';

import '../data/models/repair_model.dart';
import '../providers/repair_provider.dart';

enum _RepairExploreMode {
  map,
  list,
}

class RepairsPage extends StatefulWidget {
  const RepairsPage({super.key});

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);

  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  final searchController = TextEditingController();

  Position? _currentPosition;

  RepairWorkshopModel? _selectedMapWorkshop;



  Timer? _searchDebounce;

  _RepairExploreMode _exploreMode =
      _RepairExploreMode.map;

  List<RepairWorkshopModel>
  _mapWorkshops(RepairProvider repair,) {
    final result =
    <RepairWorkshopModel>[];

    final seen = <String>{};

    final all = [
      ...repair.repairWorkshops,
      ...repair.bodyRepairWorkshops,
    ];

    for (final workshop in all) {
      final lat =
          workshop.latitude;

      final lng =
          workshop.longitude;

      if (lat == null ||
          lng == null) {
        continue;
      }

      final key =
      workshop.id != null
          ? 'id_${workshop.id}'
          : '${workshop.branchName}_$lat,$lng';

      if (seen.add(key)) {
        result.add(workshop);
      }
    }

    return result;
  }


  @override
  void initState() {
    super.initState();

    Future.microtask(
      _loadInitialData,
    );
  }

  void _onSearchChanged(
      String value,
      ) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(
        milliseconds: 450,
      ),
          () {
        if (!mounted) return;

        _search(value);
      },
    );
  }

  Future<void> _loadInitialData() async {
    final position =
    await _getCurrentPosition();

    if (!mounted) return;

    setState(() {
      _currentPosition = position;
    });

    await context
        .read<RepairProvider>()
        .loadHome(
      lat: position?.latitude,
      lng: position?.longitude,
      radius: 10,
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

  Future<void> _search(
      String value,
      ) async {
    var position =
        _currentPosition;

    if (position == null) {
      position =
      await _getCurrentPosition();

      if (!mounted) return;

      setState(() {
        _currentPosition =
            position;
      });
    }

    final repair =
    context.read<
        RepairProvider>();

    setState(() {
      _selectedMapWorkshop =
      null;
    });

    await repair.loadWorkshops(
      serviceId:
      repair.selectedService?.id,
      serviceType:
      repair.selectedService
          ?.serviceType,
      lat: position?.latitude,
      lng: position?.longitude,
      radius: 10,
      search: value,
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _showAllServices()
  async {
    final repair =
    context.read<
        RepairProvider>();

    repair.clearSelectedService();

    searchController.clear();

    setState(() {
      _selectedMapWorkshop =
      null;
    });

    await repair.loadHome(
      lat: _currentPosition
          ?.latitude,
      lng: _currentPosition
          ?.longitude,
      radius: 10,
    );
  }

  List<RepairWorkshopModel>
  _visibleMapWorkshops(
      RepairProvider repair,
      ) {
    // أثناء البحث، الـAPI result يتم وضعه
    // في repairWorkshops.
    if (repair.searchText
        .trim()
        .isNotEmpty) {
      return repair
          .repairWorkshops;
    }

    final selected =
        repair.selectedService;

    if (selected != null) {
      if (selected.serviceType ==
          'body') {
        return repair
            .bodyRepairWorkshops;
      }

      return repair
          .repairWorkshops;
    }

    final result =
    <RepairWorkshopModel>[];

    final used =
    <String>{};

    for (final workshop in [
      ...repair.repairWorkshops,
      ...repair.bodyRepairWorkshops,
    ]) {
      final key =
      workshop.id != null
          ? 'id_${workshop.id}'
          : '${workshop.branchName}_${workshop.latitude}_${workshop.longitude}';

      if (used.add(key)) {
        result.add(workshop);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final repair =
    context.watch<
        RepairProvider>();

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final mapWorkshops =
    _visibleMapWorkshops(
      repair,
    );

    return Material(
      color: isDark
          ? const Color(0xFF0B0F16)
          : const Color(0xFFF5F6F8),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color:
          RepairsPage.primaryOrange,
          onRefresh: () async {
            await _loadInitialData();
          },
          child:
          repair.isLoading &&
              repair.home ==
                  null
              ? const _RepairLoadingView()
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
                _RepairsHero(
                  vehicleName:
                  repair
                      .home
                      ?.primaryVehicle
                      ?.displayName ??
                      'No vehicle selected',
                  hasLocation:
                  _currentPosition !=
                      null,
                ),

                const SizedBox(
                  height: 16,
                ),

                _RepairSearchField(
                  controller:
                  searchController,
                  isDark:
                  isDark,
                  onChanged:
                  _onSearchChanged,
                  onSubmitted:
                  _search,
                ),

                const SizedBox(
                  height: 18,
                ),

                Padding(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 16,
                  ),
                  child:
                  _SectionHeading(
                    title:
                    'Popular services',
                    subtitle:
                    repair.selectedService ==
                        null
                        ? 'Choose a service to find the best matching workshop'
                        : 'Showing ${repair.selectedService!.name}',
                    isDark:
                    isDark,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                _ServicesSelector(
                  services:
                  repair
                      .popularServices,
                  selectedService:
                  repair
                      .selectedService,
                  isDark:
                  isDark,
                  onAllTap:
                  _showAllServices,
                  onTap:
                      (service) async {
                    await repair
                        .selectService(
                      service,
                    );

                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _selectedMapWorkshop =
                      null;
                    });

                    var position =
                        _currentPosition;

                    if (position ==
                        null) {
                      position =
                      await _getCurrentPosition();

                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        _currentPosition =
                            position;
                      });
                    }

                    await repair
                        .loadWorkshops(
                      serviceId:
                      service.id,
                      serviceType:
                      service.serviceType ??
                          'repair',
                      lat: position
                          ?.latitude,
                      lng: position
                          ?.longitude,
                      radius: 10,
                    );
                  },
                ),

                const SizedBox(
                  height: 22,
                ),

                Padding(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 16,
                  ),
                  child:
                  _ExploreHeader(
                    count:
                    mapWorkshops
                        .where(
                          (w) =>
                      w.latitude !=
                          null &&
                          w.longitude !=
                              null,
                    )
                        .length,
                    mode:
                    _exploreMode,
                    isDark:
                    isDark,
                    onChanged:
                        (mode) {
                      setState(() {
                        _exploreMode =
                            mode;
                      });
                    },
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                if (_exploreMode ==
                    _RepairExploreMode
                        .map)
                  Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 16,
                    ),
                    child:
                    _WorkshopMapCard(
                      isDark:
                      isDark,
                      currentPosition:
                      _currentPosition,
                      workshops:
                      mapWorkshops,
                      selectedWorkshop:
                      _selectedMapWorkshop,
                      onWorkshopSelected:
                          (workshop) {
                        setState(() {
                          _selectedMapWorkshop =
                              workshop;
                        });
                      },
                      onClearSelection:
                          () {
                        setState(() {
                          _selectedMapWorkshop =
                          null;
                        });
                      },
                      onBook:
                      _openRepairRequestSheet,
                    ),
                  )
                else
                  _WorkshopGroupsList(
                    repairWorkshops:
                    repair
                        .repairWorkshops,
                    bodyWorkshops:
                    repair
                        .bodyRepairWorkshops,
                    selectedService:
                    repair
                        .selectedService,
                    isDark:
                    isDark,
                    onBook:
                    _openRepairRequestSheet,
                  ),

                if (repair.isLoading &&
                    repair.home !=
                        null) ...[
                  const SizedBox(
                    height: 14,
                  ),
                  const Padding(
                    padding:
                    EdgeInsets
                        .symmetric(
                      horizontal:
                      16,
                    ),
                    child:
                    LinearProgressIndicator(
                      minHeight:
                      2,
                      color:
                      RepairsPage
                          .primaryOrange,
                      backgroundColor:
                      Colors
                          .transparent,
                    ),
                  ),
                ],

                if (repair
                    .recentRequests
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 24,
                  ),

                  Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 16,
                    ),
                    child:
                    _SectionHeading(
                      title:
                      'Recent requests',
                      subtitle:
                      'Track your latest repair activity',
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
                      horizontal: 16,
                    ),
                    physics:
                    const NeverScrollableScrollPhysics(),
                    shrinkWrap:
                    true,
                    itemCount:
                    repair
                        .recentRequests
                        .length,
                    separatorBuilder:
                        (_, __) =>
                    const SizedBox(
                      height: 8,
                    ),
                    itemBuilder:
                        (
                        _,
                        index,
                        ) {
                      return _RepairRequestTile(
                        request:
                        repair
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

class _RepairsHero
    extends StatelessWidget {
  final String vehicleName;
  final bool hasLocation;

  const _RepairsHero({
    required this.vehicleName,
    required this.hasLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.fromLTRB(
        18,
        17,
        18,
        20,
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
          Radius.circular(27),
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
                decoration:
                BoxDecoration(
                  color:
                  Colors.white
                      .withOpacity(
                    .09,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    13,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .home_repair_service_rounded,
                  color:
                  RepairsPage
                      .primaryOrange,
                  size: 21,
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
                      'Repairs & maintenance',
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
                      'Find nearby service centers and book a workshop',
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
                _HeroInfoPill(
                  icon: Icons
                      .directions_car_filled_rounded,
                  title:
                  vehicleName,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                _HeroInfoPill(
                  icon: Icons
                      .location_on_rounded,
                  title: hasLocation
                      ? 'Current location'
                      : 'Location unavailable',
                  subtitle: hasLocation
                      ? '10 mi search radius'
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _HeroInfoPill
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _HeroInfoPill({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
      const BoxConstraints(
        minHeight: 48,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color:
        Colors.white
            .withOpacity(.07),
        borderRadius:
        BorderRadius.circular(
          13,
        ),
        border: Border.all(
          color:
          Colors.white
              .withOpacity(.06),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
            RepairsPage
                .primaryOrange,
            size: 16,
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

                if (subtitle !=
                    null) ...[
                  const SizedBox(
                    height: 1,
                  ),
                  Text(
                    subtitle!,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RepairSearchField
    extends StatelessWidget {
  final TextEditingController
  controller;

  final bool isDark;

  final ValueChanged<String>
  onChanged;

  final ValueChanged<String>
  onSubmitted;

  const _RepairSearchField({
    required this.controller,
    required this.isDark,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child:
      ValueListenableBuilder<
          TextEditingValue>(
        valueListenable:
        controller,
        builder:
            (
            context,
            value,
            _,
            ) {
          return Container(
            height: 47,
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
                color: isDark
                    ? Colors.white
                    .withOpacity(
                  .07,
                )
                    : const Color(
                  0xFFE1E4E9,
                ),
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
              onSubmitted,
              style:
              TextStyle(
                color: isDark
                    ? Colors.white
                    : const Color(
                  0xFF172033,
                ),
                fontSize: 12,
              ),
              decoration:
              InputDecoration(
                hintText:
                'Search workshops or services',
                hintStyle:
                const TextStyle(
                  color:
                  Color(
                    0xFF979EA8,
                  ),
                  fontSize: 11,
                ),
                prefixIcon:
                const Icon(
                  Icons
                      .search_rounded,
                  color:
                  Color(
                    0xFF747C88,
                  ),
                  size: 20,
                ),
                suffixIcon:
                value.text
                    .isEmpty
                    ? null
                    : IconButton(
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
                    size: 17,
                  ),
                ),
                border:
                InputBorder.none,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ServicesSelector
    extends StatelessWidget {
  final List<RepairServiceModel>
  services;

  final RepairServiceModel?
  selectedService;

  final bool isDark;

  final VoidCallback onAllTap;

  final ValueChanged<
      RepairServiceModel>
  onTap;

  const _ServicesSelector({
    required this.services,
    required this.selectedService,
    required this.isDark,
    required this.onAllTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child:
      ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount:
        services.length + 1,
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
          if (index == 0) {
            return _ServiceCard(
              label:
              'All',
              icon:
              Icons
                  .apps_rounded,
              selected:
              selectedService ==
                  null,
              isDark:
              isDark,
              onTap:
              onAllTap,
            );
          }

          final service =
          services[index - 1];

          return _ServiceCard(
            label:
            service.name,
            icon:
            _repairServiceIcon(
              service.slug ??
                  service.name,
            ),
            selected:
            selectedService?.id ==
                service.id,
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


class _ServiceCard
    extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? RepairsPage
          .primaryOrange
          : isDark
          ? const Color(
        0xFF151B25,
      )
          : Colors.white,
      borderRadius:
      BorderRadius.circular(
        15,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          15,
        ),
        child: Container(
          width: 92,
          padding:
          const EdgeInsets
              .symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              15,
            ),
            border: Border.all(
              color: selected
                  ? RepairsPage
                  .primaryOrange
                  : isDark
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
            mainAxisAlignment:
            MainAxisAlignment
                .center,
            children: [
              Icon(
                icon,
                color: selected
                    ? Colors.white
                    : RepairsPage
                    .primaryOrange,
                size: 20,
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                label,
                maxLines: 1,
                overflow:
                TextOverflow
                    .ellipsis,
                style:
                TextStyle(
                  color: selected
                      ? Colors.white
                      : isDark
                      ? Colors
                      .white
                      : const Color(
                    0xFF414A57,
                  ),
                  fontSize: 9,
                  fontWeight:
                  selected
                      ? FontWeight
                      .w700
                      : FontWeight
                      .w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


IconData _repairServiceIcon(
    String key,
    ) {
  final lower =
  key.toLowerCase();

  if (lower.contains('oil')) {
    return Icons
        .oil_barrel_rounded;
  }

  if (lower.contains(
    'diagnostic',
  )) {
    return Icons
        .monitor_heart_outlined;
  }

  if (lower.contains('brake')) {
    return Icons
        .disc_full_rounded;
  }

  if (lower.contains('tire')) {
    return Icons
        .tire_repair_rounded;
  }

  if (lower.contains('a/c') ||
      lower.contains('ac')) {
    return Icons
        .ac_unit_rounded;
  }

  if (lower.contains('body') ||
      lower.contains('paint')) {
    return Icons
        .car_repair_rounded;
  }

  return Icons
      .build_circle_outlined;
}

class _ExploreHeader
    extends StatelessWidget {
  final int count;
  final _RepairExploreMode mode;
  final bool isDark;

  final ValueChanged<
      _RepairExploreMode>
  onChanged;

  const _ExploreHeader({
    required this.count,
    required this.mode,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Row(
      children: [
        Expanded(
          child:
          _SectionHeading(
            title:
            'Nearby service centers',
            subtitle:
            '$count mapped location${count == 1 ? '' : 's'}',
            isDark:
            isDark,
          ),
        ),

        Container(
          height: 35,
          padding:
          const EdgeInsets.all(
            3,
          ),
          decoration:
          BoxDecoration(
            color: isDark
                ? const Color(
              0xFF151B25,
            )
                : const Color(
              0xFFE8EBEF,
            ),
            borderRadius:
            BorderRadius.circular(
              11,
            ),
          ),
          child: Row(
            children: [
              _ExploreModeButton(
                icon:
                Icons.map_outlined,
                selected:
                mode ==
                    _RepairExploreMode
                        .map,
                isDark:
                isDark,
                onTap:
                    () => onChanged(
                  _RepairExploreMode
                      .map,
                ),
              ),
              _ExploreModeButton(
                icon:
                Icons
                    .format_list_bulleted_rounded,
                selected:
                mode ==
                    _RepairExploreMode
                        .list,
                isDark:
                isDark,
                onTap:
                    () => onChanged(
                  _RepairExploreMode
                      .list,
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


class _ExploreModeButton
    extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ExploreModeButton({
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? isDark
          ? const Color(
        0xFF283142,
      )
          : Colors.white
          : Colors.transparent,
      borderRadius:
      BorderRadius.circular(
        8,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          8,
        ),
        child: SizedBox(
          width: 34,
          height: 29,
          child: Icon(
            icon,
            size: 16,
            color: selected
                ? RepairsPage
                .primaryOrange
                : const Color(
              0xFF8C939D,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkshopGroupsList
    extends StatelessWidget {
  final List<RepairWorkshopModel>
  repairWorkshops;

  final List<RepairWorkshopModel>
  bodyWorkshops;

  final RepairServiceModel?
  selectedService;

  final bool isDark;

  final ValueChanged<
      RepairWorkshopModel>
  onBook;

  const _WorkshopGroupsList({
    required this.repairWorkshops,
    required this.bodyWorkshops,
    required this.selectedService,
    required this.isDark,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final showingBodyOnly =
        selectedService
            ?.serviceType ==
            'body';

    final showingRepairOnly =
        selectedService != null &&
            !showingBodyOnly;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          if (!showingBodyOnly) ...[
            _WorkshopGroup(
              title:
              'Repair & maintenance',
              workshops:
              repairWorkshops,
              selectedService:
              selectedService,
              isDark:
              isDark,
              onBook:
              onBook,
            ),
          ],

          if (!showingRepairOnly) ...[
            if (!showingBodyOnly)
              const SizedBox(
                height: 20,
              ),

            _WorkshopGroup(
              title:
              'Body repair',
              workshops:
              bodyWorkshops,
              selectedService:
              selectedService,
              isDark:
              isDark,
              onBook:
              onBook,
            ),
          ],
        ],
      ),
    );
  }
}


class _WorkshopGroup
    extends StatelessWidget {
  final String title;

  final List<RepairWorkshopModel>
  workshops;

  final RepairServiceModel?
  selectedService;

  final bool isDark;

  final ValueChanged<
      RepairWorkshopModel>
  onBook;

  const _WorkshopGroup({
    required this.title,
    required this.workshops,
    required this.selectedService,
    required this.isDark,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
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
            ),

            Text(
              '${workshops.length}',
              style:
              const TextStyle(
                color:
                Color(
                  0xFF9198A2,
                ),
                fontSize: 9,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 9,
        ),

        if (workshops.isEmpty)
          _EmptyCard(
            text:
            'No workshops available yet.',
            isDark:
            isDark,
          )
        else
          ListView.separated(
            physics:
            const NeverScrollableScrollPhysics(),
            shrinkWrap:
            true,
            itemCount:
            workshops.length,
            separatorBuilder:
                (_, __) =>
            const SizedBox(
              height: 9,
            ),
            itemBuilder:
                (
                _,
                index,
                ) {
              final workshop =
              workshops[index];

              return _ModernWorkshopCard(
                workshop:
                workshop,
                isDark:
                isDark,
                hasSelectedService:
                selectedService !=
                    null,
                onBook:
                    () => onBook(
                  workshop,
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ModernWorkshopCard
    extends StatelessWidget {
  final RepairWorkshopModel
  workshop;

  final bool isDark;

  final bool hasSelectedService;

  final VoidCallback onBook;

  const _ModernWorkshopCard({
    required this.workshop,
    required this.isDark,
    required this.hasSelectedService,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final address =
    (workshop.address ?? '')
        .trim();

    final services =
    (workshop.servicesText ??
        '')
        .trim();

    return Container(
      padding:
      const EdgeInsets.all(
        13,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(
          0xFF151B25,
        )
            : Colors.white,
        borderRadius:
        BorderRadius.circular(
          17,
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
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration:
                BoxDecoration(
                  color: RepairsPage
                      .primaryOrange
                      .withOpacity(
                    .10,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    13,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .home_repair_service_rounded,
                  color:
                  RepairsPage
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            workshop
                                .branchName,
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
                              fontSize: 12,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ),

                        if ((workshop.tag ??
                            '')
                            .isNotEmpty)
                          Container(
                            margin:
                            const EdgeInsets
                                .only(
                              left: 6,
                            ),
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFF18A675,
                              ).withOpacity(
                                .09,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                99,
                              ),
                            ),
                            child: Text(
                              workshop
                                  .tag!,
                              style:
                              const TextStyle(
                                color:
                                Color(
                                  0xFF158764,
                                ),
                                fontSize: 7.5,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .star_rounded,
                          color:
                          Color(
                            0xFFF3AE32,
                          ),
                          size: 13,
                        ),

                        const SizedBox(
                          width: 3,
                        ),

                        Text(
                          (workshop.rating ??
                              0)
                              .toStringAsFixed(
                            1,
                          ),
                          style:
                          TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(
                              0xFF525A66,
                            ),
                            fontSize: 9.5,
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),

                        Text(
                          ' (${workshop.reviewsCount})',
                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFF979EA8,
                            ),
                            fontSize: 8.5,
                          ),
                        ),

                        if (workshop
                            .distanceMiles !=
                            null) ...[
                          const Text(
                            '  •  ',
                            style:
                            TextStyle(
                              color:
                              Color(
                                0xFFB0B5BC,
                              ),
                            ),
                          ),
                          Text(
                            '${workshop.distanceMiles!.toStringAsFixed(1)} mi',
                            style:
                            const TextStyle(
                              color:
                              Color(
                                0xFF777F8A,
                              ),
                              fontSize: 9,
                              fontWeight:
                              FontWeight
                                  .w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (address.isNotEmpty) ...[
            const SizedBox(
              height: 9,
            ),

            Row(
              children: [
                const Icon(
                  Icons
                      .location_on_outlined,
                  color:
                  Color(
                    0xFF8B929D,
                  ),
                  size: 14,
                ),

                const SizedBox(
                  width: 5,
                ),

                Expanded(
                  child: Text(
                    address,
                    maxLines: 1,
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
                ),
              ],
            ),
          ],

          if (services.isNotEmpty) ...[
            const SizedBox(
              height: 7,
            ),

            Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                services,
                maxLines: 2,
                overflow:
                TextOverflow
                    .ellipsis,
                style:
                const TextStyle(
                  color:
                  Color(
                    0xFF777F8B,
                  ),
                  fontSize: 9,
                  height: 1.3,
                ),
              ),
            ),
          ],

          const SizedBox(
            height: 11,
          ),

          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .schedule_rounded,
                      color:
                      Color(
                        0xFF8B929D,
                      ),
                      size: 14,
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Expanded(
                      child: Text(
                        workshop.nextAvailableSlot !=
                            null
                            ? 'Next: ${workshop.nextAvailableSlot}'
                            : 'Check availability',
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF7E8691,
                          ),
                          fontSize: 8.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (workshop
                  .offersPickupDropoff)
                Padding(
                  padding:
                  const EdgeInsets
                      .only(
                    right: 8,
                  ),
                  child: Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFF3975D5,
                      ).withOpacity(
                        .08,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        99,
                      ),
                    ),
                    child:
                    const Text(
                      'Pickup',
                      style:
                      TextStyle(
                        color:
                        Color(
                          0xFF3975D5,
                        ),
                        fontSize: 7.5,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ),
                ),

              SizedBox(
                height: 34,
                child:
                FilledButton(
                  onPressed:
                  onBook,
                  style:
                  FilledButton
                      .styleFrom(
                    backgroundColor:
                    RepairsPage
                        .primaryOrange,
                    foregroundColor:
                    Colors.white,
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 12,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  child: Text(
                    hasSelectedService
                        ? 'Book'
                        : 'Choose service',
                    style:
                    const TextStyle(
                      fontSize: 9,
                      fontWeight:
                      FontWeight.w700,
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

class _SectionHeading
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _SectionHeading({
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

class _RepairLoadingView
    extends StatelessWidget {
  const _RepairLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child:
      CircularProgressIndicator(
        color:
        RepairsPage.primaryOrange,
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


class _WorkshopMapCard
    extends StatelessWidget {
  final bool isDark;

  final Position? currentPosition;

  final List<RepairWorkshopModel>
  workshops;

  final RepairWorkshopModel?
  selectedWorkshop;

  final ValueChanged<
      RepairWorkshopModel>
  onWorkshopSelected;

  final VoidCallback
  onClearSelection;

  final ValueChanged<
      RepairWorkshopModel>
  onBook;

  const _WorkshopMapCard({
    required this.isDark,
    required this.currentPosition,
    required this.workshops,
    required this.selectedWorkshop,
    required this.onWorkshopSelected,
    required this.onClearSelection,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final mappedWorkshops =
    workshops.where(
          (workshop) {
        return workshop.latitude !=
            null &&
            workshop.longitude != null;
      },
    ).toList();

    final LatLng? userPoint =
    currentPosition == null
        ? null
        : LatLng(
      currentPosition!
          .latitude,
      currentPosition!
          .longitude,
    );

    LatLng? initialCenter;

    if (userPoint != null) {
      initialCenter = userPoint;
    } else if (mappedWorkshops
        .isNotEmpty) {
      initialCenter = LatLng(
        mappedWorkshops
            .first.latitude!,
        mappedWorkshops
            .first.longitude!,
      );
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    'Nearby service centers',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : const Color(
                        0xFF172033,
                      ),
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    mappedWorkshops
                        .isEmpty
                        ? 'No workshop locations available'
                        : '${mappedWorkshops.length} location${mappedWorkshops.length == 1 ? '' : 's'} near you',
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF8A919C,
                      ),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            if (currentPosition !=
                null)
              Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration:
                BoxDecoration(
                  color: RepairsPage
                      .primaryOrange
                      .withOpacity(
                    .09,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    99,
                  ),
                ),
                child:
                const Row(
                  mainAxisSize:
                  MainAxisSize
                      .min,
                  children: [
                    Icon(
                      Icons
                          .my_location_rounded,
                      size: 12,
                      color:
                      RepairsPage
                          .primaryOrange,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Near you',
                      style:
                      TextStyle(
                        color:
                        RepairsPage
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
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(
              0xFF151B25,
            )
                : const Color(
              0xFFEDEFF2,
            ),
            borderRadius:
            BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white
                  .withOpacity(
                .06,
              )
                  : const Color(
                0xFFE1E4E8,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(
              19,
            ),
            child:
            initialCenter ==
                null
                ? _NoMapLocation(
              isDark:
              isDark,
            )
                : Stack(
              children: [
                Positioned.fill(
                  child:
                  FlutterMap(
                    options:
                    MapOptions(
                      initialCenter:
                      initialCenter,
                      initialZoom:
                      userPoint !=
                          null
                          ? 12
                          : 11,
                      minZoom: 3,
                      maxZoom: 18,
                    ),
                    children: [
                      ColorFiltered(
                        colorFilter:
                        ColorFilter
                            .mode(
                          isDark
                              ? const Color(
                            0xFF172033,
                          )
                              .withOpacity(
                            .42,
                          )
                              : const Color(
                            0xFFFFF4EA,
                          )
                              .withOpacity(
                            .16,
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
                              width: 30,
                              height:
                              30,
                              child:
                              const _CurrentLocationMarker(),
                            ),

                          ...mappedWorkshops.map(
                                (
                                workshop,
                                ) {
                              final selected =
                                  selectedWorkshop
                                      ?.id !=
                                      null &&
                                      selectedWorkshop!
                                          .id ==
                                          workshop
                                              .id;

                              return Marker(
                                point:
                                LatLng(
                                  workshop
                                      .latitude!,
                                  workshop
                                      .longitude!,
                                ),
                                width:
                                44,
                                height:
                                44,
                                child:
                                _WorkshopMapMarker(
                                  selected:
                                  selected,
                                  onTap:
                                      () {
                                    onWorkshopSelected(
                                      workshop,
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

                // App-styled overlay
                Positioned.fill(
                  child:
                  IgnorePointer(
                    child:
                    Container(
                      decoration:
                      BoxDecoration(
                        color: isDark
                            ? const Color(
                          0xFF172033,
                        )
                            .withOpacity(
                          .05,
                        )
                            : RepairsPage
                            .primaryOrange
                            .withOpacity(
                          .015,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 10,
                  top: 10,
                  child:
                  _MapPill(
                    icon: Icons
                        .home_repair_service_outlined,
                    text:
                    '${mappedWorkshops.length} shops',
                  ),
                ),

                const Positioned(
                  right: 8,
                  bottom: 7,
                  child: Text(
                    '© OpenStreetMap contributors',
                    style:
                    TextStyle(
                      color:
                      Color(
                        0xFF606873,
                      ),
                      fontSize:
                      7,
                      fontWeight:
                      FontWeight
                          .w500,
                    ),
                  ),
                ),

                if (selectedWorkshop !=
                    null)
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 20,
                    child:
                    _SelectedWorkshopMapCard(
                      workshop:
                      selectedWorkshop!,
                      onClose:
                      onClearSelection,
                      onBook:
                          () {
                        onBook(
                          selectedWorkshop!,
                        );
                      },
                    ),
                  ),
              ],
            ),
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























class _WorkshopMapMarker
    extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _WorkshopMapMarker({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 180,
        ),
        width: selected
            ? 42
            : 36,
        height: selected
            ? 42
            : 36,
        decoration: BoxDecoration(
          color: selected
              ? const Color(
            0xFF172033,
          )
              : RepairsPage
              .primaryOrange,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: selected
                ? 3
                : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(.20),
              blurRadius: 8,
              offset:
              const Offset(
                0,
                3,
              ),
            ),
          ],
        ),
        child: const Icon(
          Icons
              .home_repair_service_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}


class _CurrentLocationMarker
    extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color:
        const Color(
          0xFF3478F6,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF3478F6,
            ).withOpacity(.30),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }
}


class _MapPill
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MapPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
        const Color(
          0xE6172033,
        ),
        borderRadius:
        BorderRadius.circular(
          99,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.10),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color:
            Colors.white,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,
            style:
            const TextStyle(
              color:
              Colors.white,
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


class _SelectedWorkshopMapCard
    extends StatelessWidget {
  final RepairWorkshopModel
  workshop;

  final VoidCallback onClose;
  final VoidCallback onBook;

  const _SelectedWorkshopMapCard({
    required this.workshop,
    required this.onClose,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        11,
        10,
        8,
        10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
            blurRadius: 18,
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
            width: 38,
            height: 38,
            decoration:
            BoxDecoration(
              color: RepairsPage
                  .primaryOrange
                  .withOpacity(
                .10,
              ),
              borderRadius:
              BorderRadius
                  .circular(
                11,
              ),
            ),
            child:
            const Icon(
              Icons
                  .home_repair_service_rounded,
              color:
              RepairsPage
                  .primaryOrange,
              size: 18,
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
                  workshop
                      .branchName,
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
                    fontSize: 11,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .star_rounded,
                      size: 12,
                      color:
                      Color(
                        0xFFF3AE32,
                      ),
                    ),

                    const SizedBox(
                      width: 3,
                    ),

                    Text(
                      (workshop.rating ??
                          0)
                          .toStringAsFixed(
                        1,
                      ),
                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF555D68,
                        ),
                        fontSize: 9,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),

                    if (workshop
                        .distanceMiles !=
                        null) ...[
                      const Text(
                        '  •  ',
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFFA1A6AE,
                          ),
                          fontSize: 8,
                        ),
                      ),

                      Text(
                        '${workshop.distanceMiles!.toStringAsFixed(1)} mi',
                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF777F8B,
                          ),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),

                if ((workshop.address ??
                    '')
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    workshop
                        .address!,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF9298A2,
                      ),
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(
            width: 5,
          ),

          SizedBox(
            height: 32,
            child:
            FilledButton(
              onPressed: onBook,
              style:
              FilledButton
                  .styleFrom(
                backgroundColor:
                RepairsPage
                    .primaryOrange,
                foregroundColor:
                Colors.white,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 11,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    10,
                  ),
                ),
              ),
              child:
              const Text(
                'Book',
                style:
                TextStyle(
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ),

          IconButton(
            visualDensity:
            VisualDensity
                .compact,
            constraints:
            const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
            padding:
            EdgeInsets.zero,
            onPressed: onClose,
            icon:
            const Icon(
              Icons.close_rounded,
              color:
              Color(
                0xFF9AA0A9,
              ),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}


class _NoMapLocation
    extends StatelessWidget {
  final bool isDark;

  const _NoMapLocation({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment:
      Alignment.center,
      padding:
      const EdgeInsets.all(
        24,
      ),
      color: isDark
          ? const Color(
        0xFF151B25,
      )
          : const Color(
        0xFFF0F1F3,
      ),
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
            BoxDecoration(
              color: RepairsPage
                  .primaryOrange
                  .withOpacity(
                .08,
              ),
              shape:
              BoxShape.circle,
            ),
            child:
            const Icon(
              Icons
                  .location_off_outlined,
              color:
              RepairsPage
                  .primaryOrange,
              size: 22,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Text(
            'No map locations available',
            style:
            TextStyle(
              color: isDark
                  ? Colors.white
                  : const Color(
                0xFF172033,
              ),
              fontSize: 11,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          const Text(
            'Workshop locations will appear here when coordinates are available.',
            textAlign:
            TextAlign.center,
            style:
            TextStyle(
              color:
              Color(
                0xFF8A919C,
              ),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}