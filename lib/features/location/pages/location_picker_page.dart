import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationSelection {
  final LatLng point;
  final String address;

  const LocationSelection({
    required this.point,
    required this.address,
  });
}

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialPoint;
  final String? initialAddress;

  const LocationPickerPage({
    super.key,
    this.initialPoint,
    this.initialAddress,
  });

  @override
  State<LocationPickerPage> createState() =>
      _LocationPickerPageState();
}

class _LocationPickerPageState
    extends State<LocationPickerPage> {
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

    if ((widget.initialAddress ?? '').trim().isNotEmpty) {
      selectedAddress = widget.initialAddress!.trim();
    } else if (selectedPoint != null) {
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
        final alreadyExists = uniqueParts.any(
              (item) =>
          item.toLowerCase() == part.toLowerCase(),
        );

        if (!alreadyExists) {
          uniqueParts.add(part);
        }
      }

      if (!mounted) return;

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

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
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
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not get your current location.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingCurrentLocation = false;
        });
      }
    }
  }

  void _confirmLocation() {
    final point = selectedPoint;

    if (point == null) return;

    Navigator.pop(
      context,
      LocationSelection(
        point: point,
        address: selectedAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        body: SizedBox.expand(
          child: Stack(
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
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                  'com.koshy.koshy.talabatfresh',
                ),

                if (selectedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedPoint!,
                        width: 54,
                        height: 54,
                        child: const Icon(
                          Icons.location_pin,
                          size: 48,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // OSM attribution
          Positioned(
            right: 8,
            bottom: 188,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.88),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(
                  color: Color(0xFF555B65),
                  fontSize: 8,
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                10,
                14,
                0,
              ),
              child: Row(
                children: [
                  _MapButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  const Spacer(),

                  Container(
                    height: 44,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(.10),
                          blurRadius: 14,
                          offset:
                          const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Choose location',
                      style: TextStyle(
                        color: ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 14,
            bottom: 215,
            child: _MapButton(
              icon: Icons.my_location_rounded,
              loading: loadingCurrentLocation,
              onTap: _useCurrentLocation,
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(.14),
                      blurRadius: 24,
                      offset:
                      const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECTED LOCATION',
                      style: TextStyle(
                        color: Color(0xFF969CA6),
                        fontSize: 9,
                        letterSpacing: .8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: orange.withOpacity(.10),
                            borderRadius:
                            BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: orange,
                            size: 19,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: resolvingAddress
                              ? const Padding(
                            padding:
                            EdgeInsets.only(top: 8),
                            child: Text(
                              'Finding address...',
                              style: TextStyle(
                                color:
                                Color(0xFF858C97),
                                fontSize: 11,
                              ),
                            ),
                          )
                              : Text(
                            selectedAddress,
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 12,
                              height: 1.35,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 46,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                        selectedPoint == null ||
                            resolvingAddress
                            ? null
                            : _confirmLocation,
                        style: FilledButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          const Color(0xFFE2E4E8),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(13),
                          ),
                        ),
                        child: const Text(
                          'Use this location',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;

  const _MapButton({
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 46,
          height: 46,
          child: loading
              ? const Padding(
            padding: EdgeInsets.all(14),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _LocationPickerPageState.orange,
            ),
          )
              : Icon(
            icon,
            size: 21,
            color: _LocationPickerPageState.ink,
          ),
        ),
      ),
    );
  }
}