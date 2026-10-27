import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  final LatLng? initialPoint;

  const MapPage({
    super.key,
    this.initialPoint,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const Color orange = Color(0xFFF57C00);
  static const Color ink = Color(0xFF172033);

  LatLng? selectedPoint;
  late LatLng mapCenter;

  String selectedAddress = 'Tap the map to choose a location';

  bool resolvingAddress = false;
  bool loadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();

    mapCenter =
        widget.initialPoint ?? LatLng(30.0444, 31.2357);

    selectedPoint = widget.initialPoint;

    if (selectedPoint != null) {
      Future.microtask(
            () => _resolveAddress(selectedPoint!),
      );
    }
  }

  Future<void> _selectPoint(LatLng point) async {
    setState(() {
      selectedPoint = point;
    });

    await _resolveAddress(point);
  }

  Future<void> _resolveAddress(LatLng point) async {
    setState(() {
      resolvingAddress = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (!mounted) return;

      if (placemarks.isEmpty) {
        setState(() {
          selectedAddress = 'Selected location';
        });

        return;
      }

      final p = placemarks.first;

      final parts = <String>[
        if ((p.street ?? '').trim().isNotEmpty)
          p.street!.trim(),
        if ((p.subLocality ?? '').trim().isNotEmpty)
          p.subLocality!.trim(),
        if ((p.locality ?? '').trim().isNotEmpty)
          p.locality!.trim(),
        if ((p.administrativeArea ?? '').trim().isNotEmpty)
          p.administrativeArea!.trim(),
        if ((p.country ?? '').trim().isNotEmpty)
          p.country!.trim(),
      ];

      final uniqueParts = <String>[];

      for (final part in parts) {
        if (!uniqueParts.any(
              (item) =>
          item.toLowerCase() == part.toLowerCase(),
        )) {
          uniqueParts.add(part);
        }
      }

      setState(() {
        selectedAddress = uniqueParts.isEmpty
            ? 'Selected location'
            : uniqueParts.join(', ');
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        selectedAddress = 'Selected location';
      });
    } finally {
      if (mounted) {
        setState(() {
          resolvingAddress = false;
        });
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    if (loadingCurrentLocation) return;

    setState(() {
      loadingCurrentLocation = true;
    });

    try {
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enable location services.',
            ),
          ),
        );

        return;
      }

      var permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is required.',
            ),
          ),
        );

        return;
      }

      final position =
      await Geolocator.getCurrentPosition();

      final point = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        mapCenter = point;
        selectedPoint = point;
      });

      await _resolveAddress(point);
    } finally {
      if (mounted) {
        setState(() {
          loadingCurrentLocation = false;
        });
      }
    }
  }

  void _confirm() {
    if (selectedPoint == null) return;

    Navigator.pop(
      context,
      selectedPoint,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              key: ValueKey(
                '${mapCenter.latitude}-${mapCenter.longitude}',
              ),
              options: MapOptions(
                center: mapCenter,
                zoom: 15,
                onTap: (_, point) {
                  _selectPoint(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const [
                    'a',
                    'b',
                    'c',
                  ],
                ),

                if (selectedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 60,
                        height: 60,
                        point: selectedPoint!,
                        child: const Icon(
                          Icons.location_pin,
                          color: orange,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                0,
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    elevation: 3,
                    borderRadius:
                    BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () =>
                          Navigator.pop(context),
                      borderRadius:
                      BorderRadius.circular(14),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: ink,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withOpacity(.10),
                          blurRadius: 12,
                          offset:
                          const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Choose location',
                      style: TextStyle(
                        color: ink,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 185,
            child: Material(
              elevation: 3,
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(15),
              child: InkWell(
                onTap: _useCurrentLocation,
                borderRadius:
                BorderRadius.circular(15),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: loadingCurrentLocation
                      ? const Padding(
                    padding:
                    EdgeInsets.all(15),
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: orange,
                    ),
                  )
                      : const Icon(
                    Icons.my_location_rounded,
                    color: orange,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: SafeArea(
              top: false,
              child: Container(
                padding:
                const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(.12),
                      blurRadius: 22,
                      offset:
                      const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected location',
                      style: TextStyle(
                        color: Color(0xFF8A919C),
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons
                              .location_on_rounded,
                          color: orange,
                          size: 20,
                        ),

                        const SizedBox(width: 7),

                        Expanded(
                          child: resolvingAddress
                              ? const Padding(
                            padding:
                            EdgeInsets.only(
                              top: 3,
                            ),
                            child: Text(
                              'Finding address...',
                              style:
                              TextStyle(
                                color:
                                Color(
                                  0xFF747B87,
                                ),
                                fontSize:
                                11,
                              ),
                            ),
                          )
                              : Text(
                            selectedAddress,
                            maxLines: 2,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              color: ink,
                              fontSize: 12,
                              height: 1.35,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 13),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed:
                        selectedPoint == null
                            ? null
                            : _confirm,
                        style:
                        FilledButton.styleFrom(
                          backgroundColor:
                          orange,
                          disabledBackgroundColor:
                          const Color(
                            0xFFE3E5E8,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              13,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Use this location',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
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