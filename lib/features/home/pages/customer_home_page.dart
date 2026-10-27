import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/features/home/pages/home_search_page.dart';
import 'package:talabatfresh/features/location/pages/location_picker_page.dart';
import 'package:talabatfresh/features/notifications/pages/notifications_page.dart';

import '../../../core/constants/cache_keys.dart';
import '../../../core/constants/url_api.dart';
import '../../../data/local/cache_helper.dart';
import '../../part_requests/pages/create_part_request_page.dart';
import '../../repair/pages/repairs_page.dart';
import '../../roadside/pages/roadside_page.dart';
import '../data/models/customer_home_model.dart';
import '../providers/customer_home_provider.dart';

class HomePage extends StatefulWidget {
  // Keep these for RootShell compatibility.
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

  static const Color orange = Color(0xFFF57C00);
  static const Color ink = Color(0xFF172033);
  static const Color background = Color(0xFFF5F6F8);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _locationLabel = 'Finding location...';
  bool _isLoadingLocation = false;

  LatLng? _selectedLocation;
  bool _hasManualLocation = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CustomerHomeProvider>().loadHome();
    });

    _initializeLocation();
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    if (!mounted) return;

    context.read<CustomerHomeProvider>().refreshHome();
  }

  void _requestPart() {
    _openPage(const CreatePartRequestPage());
  }

  void _requestTires() {
    _openPage(const CreatePartRequestPage(categoryType: 'tires'));
  }

  void _bookService() {
    _openPage(const RepairsPage());
  }

  void _roadsideHelp() {
    _openPage(const RoadsidePage());
  }

  Future<void> _loadCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          _locationLabel = 'Enable location';
        });

        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _locationLabel = 'Location unavailable';
        });

        return;
      }

      final position = await Geolocator.getCurrentPosition();

      _selectedLocation = LatLng(position.latitude, position.longitude);

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isEmpty) {
        setState(() {
          _locationLabel = 'Current location';
        });
        return;
      }

      final place = placemarks.first;

      final city = (place.locality ?? '').trim();

      final subArea = (place.subAdministrativeArea ?? '').trim();

      final area = (place.administrativeArea ?? '').trim();

      final country = (place.country ?? '').trim();

      final parts = <String>[];

      if (city.isNotEmpty) {
        parts.add(city);
      } else if (subArea.isNotEmpty) {
        parts.add(subArea);
      }

      if (area.isNotEmpty &&
          !parts.any((e) => e.toLowerCase() == area.toLowerCase())) {
        parts.add(area);
      }

      if (parts.isEmpty && country.isNotEmpty) {
        parts.add(country);
      }

      setState(() {
        _locationLabel = parts.isEmpty ? 'Current location' : parts.join(', ');
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _locationLabel = 'Location unavailable';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _openSearch({bool startVoice = false}) {
    _openPage(HomeSearchPage(startVoice: startVoice));
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<LocationSelection>(
      MaterialPageRoute(
        builder:
            (_) => LocationPickerPage(
              initialPoint: _selectedLocation,
              initialAddress: _locationLabel,
            ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _selectedLocation = result.point;
      _locationLabel = result.address;
      _hasManualLocation = true;
    });

    await Future.wait([
      CacheHelper.saveData(
        key: CacheKeys.homeLocationLatitude,
        value: result.point.latitude,
      ),
      CacheHelper.saveData(
        key: CacheKeys.homeLocationLongitude,
        value: result.point.longitude,
      ),
      CacheHelper.saveData(
        key: CacheKeys.homeLocationAddress,
        value: result.address,
      ),
    ]);
  }

  Future<void> _initializeLocation() async {
    final latValue = CacheHelper.getData(key: CacheKeys.homeLocationLatitude);

    final lngValue = CacheHelper.getData(key: CacheKeys.homeLocationLongitude);

    final addressValue = CacheHelper.getData(
      key: CacheKeys.homeLocationAddress,
    );

    final latitude =
        latValue is num
            ? latValue.toDouble()
            : double.tryParse(latValue?.toString() ?? '');

    final longitude =
        lngValue is num
            ? lngValue.toDouble()
            : double.tryParse(lngValue?.toString() ?? '');

    final address = addressValue?.toString().trim() ?? '';

    if (latitude != null && longitude != null && address.isNotEmpty) {
      if (!mounted) return;

      setState(() {
        _selectedLocation = LatLng(latitude, longitude);

        _locationLabel = address;

        // Prevent pull-to-refresh from replacing
        // the user's saved location with GPS.
        _hasManualLocation = true;
      });

      return;
    }

    await _loadCurrentLocation();
  }

  /* @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerHomeProvider>();
    final home = provider.home;

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    if (provider.isLoading && home == null) {
      return const Scaffold(
        backgroundColor: HomePage.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.hasError && home == null) {
      return Scaffold(
        backgroundColor: HomePage.background,
        body: _ErrorView(
          message:
          provider.errorMessage ?? 'Failed to load home',
          onRetry: provider.loadHome,
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0F16)
          : HomePage.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: provider.refreshHome,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(16, 12, 16, 110),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _GarageOverview(
                  userName:
                  home?.user?.name ?? 'Welcome',
                  unreadCount:
                  home?.unreadNotificationsCount ??
                      0,
                  vehicleName:
                  home?.primaryVehicle?.displayName ??
                      'No vehicle selected',
                  vehicleDetails:
                  home?.primaryVehicle?.details ??
                      'Add your vehicle for better results',
                  hasVehicle:
                  home?.primaryVehicle != null,
                ),

                const SizedBox(height: 14),

                if ((home?.banners ?? []).isNotEmpty)
                  _BannerCarousel(
                    banners: home!.banners,
                  )
                else
                  const _FallbackBanner(),


                const SizedBox(height: 22),

                _RowSectionHeader(
                  title: 'Services',
                  actionText: 'See all',
                ),

                const SizedBox(height: 14),

                _HomeServicesRow(
                  onPart: _requestPart,
                  onTires: _requestTires,
                  onService: _bookService,
                  onRoadside: _roadsideHelp,
                ),

                const SizedBox(height: 24),

                const _RowSectionHeader(
                  title: 'Special offers',
                ),

                const SizedBox(height: 12),

                if ((home?.banners ?? []).isNotEmpty)
                  _BannerCarousel(
                    banners: home!.banners,
                  )
                else
                  const _FallbackBanner(),



                const SizedBox(height: 22),

                const _SectionTitle(
                  title: 'Quick actions',
                  subtitle:
                  'Start what you need right away',
                ),

                const SizedBox(height: 12),

                _ActionGrid(
                  onPart: _requestPart,
                  onTires: _requestTires,
                  onService: _bookService,
                  onRoadside: _roadsideHelp,
                ),

                if ((home?.featuredOffers ?? [])
                    .isNotEmpty) ...[
                  const SizedBox(height: 26),

                  const _SectionTitle(
                    title: 'Offers for your car',
                    subtitle:
                    'Deals and services worth checking',
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 174,
                    child: ListView.separated(
                      scrollDirection:
                      Axis.horizontal,
                      itemCount:
                      home!.featuredOffers.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        return _OfferCard(
                          offer:
                          home.featuredOffers[index],
                        );
                      },
                    ),
                  ),
                ],

                if ((home?.recentActivities ?? [])
                    .isNotEmpty) ...[
                  const SizedBox(height: 26),

                  const _SectionTitle(
                    title: 'Recent activity',
                    subtitle:
                    'Latest updates across your account',
                  ),

                  const SizedBox(height: 12),

                  ...home!.recentActivities.map(
                        (activity) => Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 9,
                      ),
                      child: _ActivityCard(
                        activity: activity,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }*/
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerHomeProvider>();

    final home = provider.home;

    if (provider.isLoading && home == null) {
      return const Scaffold(
        backgroundColor: HomePage.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.hasError && home == null) {
      return Scaffold(
        backgroundColor: HomePage.background,
        body: _ErrorView(
          message: provider.errorMessage ?? 'Failed to load home',
          onRetry: provider.loadHome,
        ),
      );
    }

    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: HomePage.background,
        body: RefreshIndicator(
          onRefresh: () async {
            await provider.refreshHome();
            if (!_hasManualLocation) {
              await _loadCurrentLocation();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _HomeHero(
                  topInset: topInset,
                  userName: home?.user?.name ?? 'Welcome',
                  unreadCount: home?.unreadNotificationsCount ?? 0,
                  location: _locationLabel,
                  isLoadingLocation: _isLoadingLocation,
                  vehicleName:
                      home?.primaryVehicle?.displayName ??
                      'No vehicle selected',
                  vehicleDetails:
                      home?.primaryVehicle?.details ?? 'Add your vehicle',
                  onLocationTap: _openLocationPicker,
                  onSearchTap: () => _openSearch(),
                  onVoiceTap: () => _openSearch(startVoice: true),

                  onNotificationTap: () {
                    _openPage(
                      const NotificationsPage(),
                    );
                  },
                ),

                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
                    decoration: const BoxDecoration(
                      color: HomePage.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _RowSectionHeader(title: 'Special offers'),

                        const SizedBox(height: 11),

                        if ((home?.banners ?? []).isNotEmpty)
                          _BannerCarousel(banners: home!.banners)
                        else
                          const _FallbackBanner(),


                        const SizedBox(height: 24),


                        const _RowSectionHeader(title: 'Services'),

                        const SizedBox(height: 13),

                        _HomeServicesRow(
                          onPart: _requestPart,
                          onTires: _requestTires,
                          onService: _bookService,
                          onRoadside: _roadsideHelp,
                        ),


                        if ((home?.featuredOffers ?? []).isNotEmpty) ...[
                          const SizedBox(height: 25),

                          const _SectionTitle(
                            title: 'Offers for your car',
                            subtitle: 'Deals worth checking',
                          ),

                          const SizedBox(height: 11),

                          SizedBox(
                            height: 174,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: home!.featuredOffers.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 12),
                              itemBuilder:
                                  (_, index) => _OfferCard(
                                    offer: home.featuredOffers[index],
                                  ),
                            ),
                          ),
                        ],

                        if ((home?.recentActivities ?? []).isNotEmpty) ...[
                          const SizedBox(height: 25),

                          const _SectionTitle(
                            title: 'Recent activity',
                            subtitle: 'Your latest updates',
                          ),

                          const SizedBox(height: 11),

                          ...home!.recentActivities.map(
                            (activity) => Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: _ActivityCard(activity: activity),
                            ),
                          ),
                        ],
                      ],
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

class _GarageOverview extends StatelessWidget {
  final String userName;
  final int unreadCount;
  final String vehicleName;
  final String vehicleDetails;
  final bool hasVehicle;

  const _GarageOverview({
    required this.userName,
    required this.unreadCount,
    required this.vehicleName,
    required this.vehicleDetails,
    required this.hasVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.60),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.09),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: HomePage.orange,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            'YOUR VEHICLE',
            style: TextStyle(
              color: Colors.white.withOpacity(.44),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .9,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const Icon(
                Icons.directions_car_filled_rounded,
                color: HomePage.orange,
                size: 20,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  vehicleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white54,
              ),
            ],
          ),

          if (vehicleDetails.isNotEmpty) ...[
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                vehicleDetails,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(.48),
                  fontSize: 10,
                ),
              ),
            ),
          ],

          const SizedBox(height: 17),

          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: Color(0xFF9AA1AC), size: 20),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'What does your car need?',
                    style: TextStyle(color: Color(0xFF7E8591), fontSize: 12),
                  ),
                ),
                Icon(Icons.tune_rounded, color: HomePage.orange, size: 19),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  final List<HomeBannerModel> banners;

  const _BannerCarousel({required this.banners});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final PageController _controller = PageController();

  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (value) {
              setState(() {
                _index = value;
              });
            },
            itemBuilder: (_, index) {
              return _BannerCard(banner: widget.banners[index]);
            },
          ),
        ),

        if (widget.banners.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (index) {
              final active = index == _index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: active ? HomePage.orange : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final HomeBannerModel banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    final imageUrl = UrlApi.assetUrl(banner.imagePath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const _BannerBackground();
              },
            )
          else
            const _BannerBackground(),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.76),
                  Colors.black.withOpacity(0.38),
                  Colors.black.withOpacity(0.06),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(17),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 230,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'FOR YOUR CAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          letterSpacing: .8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      banner.title ?? 'Everything your car needs',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    if ((banner.subtitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        banner.subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
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

class _BannerBackground extends StatelessWidget {
  const _BannerBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF242E3D),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 24),
          child: Icon(
            Icons.directions_car_rounded,
            size: 72,
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF242E3D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Everything your car needs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Parts, tires, maintenance and roadside help in one place.',
                  style: TextStyle(
                    color: Color(0xFFB9C1CC),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: HomePage.orange.withOpacity(.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: HomePage.orange,
              size: 31,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: HomePage.ink,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF89909D), fontSize: 11),
        ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final VoidCallback onPart;
  final VoidCallback onTires;
  final VoidCallback onService;
  final VoidCallback onRoadside;

  const _ActionGrid({
    required this.onPart,
    required this.onTires,
    required this.onService,
    required this.onRoadside,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: width,
              child: _ActionCard(
                icon: Icons.settings_rounded,
                title: 'Request a Part',
                subtitle: 'Get vendor quotes',
                onTap: onPart,
              ),
            ),
            SizedBox(
              width: width,
              child: _ActionCard(
                icon: Icons.tire_repair_rounded,
                title: 'Tire Quote',
                subtitle: 'Find the right tires',
                onTap: onTires,
              ),
            ),
            SizedBox(
              width: width,
              child: _ActionCard(
                icon: Icons.home_repair_service_rounded,
                title: 'Book Service',
                subtitle: 'Find nearby workshops',
                onTap: onService,
              ),
            ),
            SizedBox(
              width: width,
              child: _ActionCard(
                icon: Icons.electric_bolt_rounded,
                title: 'Roadside Help',
                subtitle: 'Get help right now',
                urgent: true,
                onTap: onRoadside,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool urgent;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = urgent ? const Color(0xFFFFF4E8) : Colors.white;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 104,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  urgent
                      ? HomePage.orange.withOpacity(0.22)
                      : const Color(0xFFE7E9ED),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: HomePage.orange.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: HomePage.orange, size: 19),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFA1A7B1),
                    size: 17,
                  ),
                ],
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: HomePage.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF8B929D), fontSize: 9.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final FeaturedOfferModel offer;

  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final imageUrl = UrlApi.assetUrl(offer.imagePath);

    return Container(
      width: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E9ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 72,
            width: double.infinity,
            child:
                imageUrl.isNotEmpty
                    ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _OfferFallback(),
                    )
                    : const _OfferFallback(),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if ((offer.discountText ?? '').isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: HomePage.orange.withOpacity(.10),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            offer.discountText!,
                            style: const TextStyle(
                              color: HomePage.orange,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    offer.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: HomePage.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    offer.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF858C98),
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferFallback extends StatelessWidget {
  const _OfferFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEF0F3),
      child: const Center(
        child: Icon(
          Icons.local_offer_outlined,
          color: HomePage.orange,
          size: 26,
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final RecentActivityModel activity;

  const _ActivityCard({required this.activity});

  Color _statusColor() {
    switch (activity.status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return const Color(0xFF18A675);

      case 'confirmed':
      case 'in_progress':
      case 'shipped':
      case 'on_the_way':
        return const Color(0xFF3975D5);

      case 'cancelled':
      case 'rejected':
      case 'failed':
        return const Color(0xFFD9534F);

      default:
        return HomePage.orange;
    }
  }

  IconData _icon() {
    switch (activity.type.toLowerCase()) {
      case 'repair':
        return Icons.home_repair_service_rounded;

      case 'roadside':
        return Icons.electric_bolt_rounded;

      case 'order':
        return Icons.shopping_bag_outlined;

      default:
        return Icons.history_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E9ED)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon(), color: statusColor, size: 19),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HomePage.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.type,
                  style: const TextStyle(
                    color: Color(0xFF9298A2),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.10),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              activity.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: HomePage.orange,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _HomeServicesRow extends StatelessWidget {
  final VoidCallback onPart;
  final VoidCallback onTires;
  final VoidCallback onService;
  final VoidCallback onRoadside;

  const _HomeServicesRow({
    required this.onPart,
    required this.onTires,
    required this.onService,
    required this.onRoadside,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ServiceShortcut(
            icon: Icons.settings_rounded,
            label: 'Parts',
            onTap: onPart,
          ),
        ),
        Expanded(
          child: _ServiceShortcut(
            icon: Icons.tire_repair_rounded,
            label: 'Tires',
            onTap: onTires,
          ),
        ),
        Expanded(
          child: _ServiceShortcut(
            icon: Icons.build_rounded,
            label: 'Service',
            onTap: onService,
          ),
        ),
        Expanded(
          child: _ServiceShortcut(
            icon: Icons.electric_bolt_rounded,
            label: 'Roadside',
            onTap: onRoadside,
          ),
        ),
      ],
    );
  }
}

class _ServiceShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ServiceShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: HomePage.orange.withOpacity(.09),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: HomePage.orange, size: 24),
            ),

            const SizedBox(height: 8),

            Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: HomePage.ink,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;

  const _RowSectionHeader({required this.title, this.actionText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: HomePage.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        if (actionText != null)
          Text(
            actionText!,
            style: const TextStyle(
              color: HomePage.orange,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _HomeHero extends StatelessWidget {
  final double topInset;
  final String userName;
  final int unreadCount;

  final String location;
  final bool isLoadingLocation;

  final String vehicleName;
  final String vehicleDetails;

  final VoidCallback onLocationTap;
  final VoidCallback onSearchTap;
  final VoidCallback onVoiceTap;
  final VoidCallback onNotificationTap;

  const _HomeHero({
    required this.topInset,
    required this.userName,
    required this.unreadCount,
    required this.location,
    required this.isLoadingLocation,
    required this.vehicleName,
    required this.vehicleDetails,
    required this.onLocationTap,
    required this.onSearchTap,
    required this.onVoiceTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172033), Color(0xFF202B3D)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: 38,
            child: Container(
              width: 175,
              height: 175,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
            ),
          ),

          Positioned(
            right: -15,
            top: 78,
            child: Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: HomePage.orange.withOpacity(.15)),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Good morning, $userName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onNotificationTap,
                            borderRadius:
                            BorderRadius.circular(12),
                            child: Container(
                              width: 39,
                              height: 39,
                              decoration: BoxDecoration(
                                color:
                                Colors.white.withOpacity(.10),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        if (unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 15,
                              height: 15,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: HomePage.orange,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Text(
                  'Location',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.55),
                    fontSize: 9,
                  ),
                ),

                const SizedBox(height: 3),

                InkWell(
                  onTap: onLocationTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: HomePage.orange,
                          size: 17,
                        ),

                        const SizedBox(width: 4),

                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        if (isLoadingLocation)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.white70,
                            ),
                          )
                        else
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white54,
                            size: 17,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 13),

                Row(
                  children: [
                    const Icon(
                      Icons.directions_car_filled_rounded,
                      color: HomePage.orange,
                      size: 17,
                    ),

                    const SizedBox(width: 7),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicleName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          if (vehicleDetails.isNotEmpty)
                            Text(
                              vehicleDetails,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(.45),
                                fontSize: 9,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        child: InkWell(
                          onTap: onSearchTap,
                          borderRadius: BorderRadius.circular(13),
                          child: const SizedBox(
                            height: 47,
                            child: Row(
                              children: [
                                SizedBox(width: 14),
                                Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF8D94A0),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Search parts, tires and brands',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFF8D94A0),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 9),

                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      child: InkWell(
                        onTap: onVoiceTap,
                        borderRadius: BorderRadius.circular(13),
                        child: const SizedBox(
                          width: 47,
                          height: 47,
                          child: Icon(
                            Icons.mic_none_rounded,
                            color: HomePage.orange,
                            size: 21,
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
