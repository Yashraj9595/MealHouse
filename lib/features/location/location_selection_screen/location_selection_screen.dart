import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:meal_house/core/app_export.dart';
import 'package:meal_house/core/services/location_service.dart';
import 'package:meal_house/core/di/service_locator.dart';

import 'package:meal_house/features/pickup_points/data/services/pickup_service.dart';
import './widgets/location_map_bottom_sheet_widget.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});
  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isDetectingLocation = false;
  bool _isSearching = false;

  late AnimationController _listController;

  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;

  // Pickup points from backend (used as popular area suggestions)
  List<Map<String, dynamic>> _pickupSuggestions = [];
  bool _loadingSuggestions = true;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(() => setState(() {}));

    _fetchPickupSuggestions();
  }

  Future<void> _fetchPickupSuggestions() async {
    try {
      final response = await sl<PickupService>().getAllPickupPoints();
      final List raw = (response.data?['data']?['pickupPoints'] as List?) ?? [];
      final suggestions = raw.map<Map<String, dynamic>>((e) {
        final doc = Map<String, dynamic>.from(e as Map);
        final coords = doc['location']?['coordinates'];
        final double lat = coords is List && coords.length >= 2
            ? (coords[1] as num).toDouble()
            : 0.0;
        final double lon = coords is List && coords.length >= 2
            ? (coords[0] as num).toDouble()
            : 0.0;
        return {
          'name':    doc['name'] as String? ?? 'Pickup Point',
          'area':    doc['address'] as String? ?? '',
          'address': doc['address'] as String? ?? '',
          'lat':     lat,
          'lon':     lon,
          'tag':     'Hub',
        };
      }).toList();

      if (mounted) {
        setState(() {
          _pickupSuggestions = suggestions;
          _loadingSuggestions = false;
        });
        _listController.reset();
        _listController.forward();
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSuggestions = false);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _listController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.isEmpty) {
      setState(() { _searchResults = []; _isSearching = false; });
      _listController.reset();
      _listController.forward();
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _fetchNominatimSuggestions(query);
    });
  }

  Future<void> _fetchNominatimSuggestions(String query) async {
    try {
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query, 'format': 'json',
          'addressdetails': 1, 'limit': 6, 'countrycodes': 'in',
        },
        options: Options(
          headers: {'User-Agent': 'MealHouseApp/1.0'},
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      if (mounted && response.statusCode == 200) {
        final List data = response.data as List;
        final results = data.map<Map<String, dynamic>>((item) {
          final addr = item['address'] ?? {};
          final city = addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['county'] ?? '';
          final suburb = addr['suburb'] ?? addr['neighbourhood'] ?? addr['road'] ?? '';
          final state = addr['state'] ?? '';
          final postcode = addr['postcode'] ?? '';
          return {
            'name': item['name'] ?? suburb,
            'displayName': item['display_name'] ?? '',
            'area': [suburb, city].where((s) => s.isNotEmpty).join(', '),
            'address': '$suburb, $city, $state $postcode'.trim(),
            'lat': double.tryParse(item['lat'] ?? '0') ?? 18.518,
            'lon': double.tryParse(item['lon'] ?? '0') ?? 73.815,
            'addressFull': addr,
          };
        }).toList();
        setState(() { _searchResults = results; _isSearching = false; });
        _listController.reset();
        _listController.forward();
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _handleCurrentLocation() async {
    if (_isDetectingLocation) return;
    setState(() => _isDetectingLocation = true);
    _focusNode.unfocus();
    try {
      final locationService = sl<LocationService>();
      final position = await locationService.getCurrentPosition();
      if (position != null) {
        final placemark = await locationService.getAddressFromLatLng(position);
        if (mounted) {
          setState(() => _isDetectingLocation = false);
          final latLng = LatLng(position.latitude, position.longitude);
          _showMapBottomSheet(
            name: placemark?.name ?? 'Current Location',
            address: placemark != null
                ? locationService.formatAddress(placemark)
                : '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
            area: _buildArea(
              placemark?.subLocality, placemark?.locality,
              placemark?.administrativeArea, placemark?.postalCode,
            ),
            position: latLng,
          );
        }
      } else {
        if (mounted) {
          setState(() => _isDetectingLocation = false);
          _showErrorSnackbar('Could not get your location. Please check permissions.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDetectingLocation = false);
        _showErrorSnackbar('Error: $e');
      }
    }
  }

  void _handleSelectFromMap() {
    _focusNode.unfocus();
    _showMapBottomSheet(
      name: 'Select on Map',
      address: 'Drag the map to pick your location',
      area: 'MIT College Area, Kothrud, Pune',
      position: const LatLng(18.5074, 73.8077),
    );
  }

  void _handleSearchResultTap(Map<String, dynamic> result) {
    _focusNode.unfocus();
    final addr = result['addressFull'] as Map? ?? {};
    _showMapBottomSheet(
      name: result['name'] ?? 'Selected Location',
      address: result['displayName'] ?? result['area'] ?? '',
      area: _buildArea(
        addr['suburb'] ?? addr['neighbourhood'],
        addr['city'] ?? addr['town'] ?? addr['village'],
        addr['state'], addr['postcode'],
      ),
      position: LatLng(result['lat'], result['lon']),
    );
  }

  String _buildArea(String? sub, String? city, String? state, String? postcode) {
    return <String>[
      if (sub != null && sub.isNotEmpty) sub,
      if (city != null && city.isNotEmpty) city,
      if (state != null && state.isNotEmpty) state,
      if (postcode != null && postcode.isNotEmpty) postcode,
    ].join(', ');
  }

  void _showMapBottomSheet({
    required String name, required String address,
    required String area, LatLng? position,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationMapBottomSheetWidget(
        locationName: name,
        addressLine1: address,
        addressLine2: area,
        initialPosition: position,
        onConfirm: (newName, newAddress, newArea, newPosition) {
          sl<LocationService>().updateSelectedLocation(newName);
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            AppRoutes.pickupPointSelectionScreen,
            arguments: {
              'lat': newPosition.latitude,
              'lon': newPosition.longitude,
              'address': newArea,
            },
          );
        },
      ),
    );
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Outfit')),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      ),
    );
  }

  // ─────────────────── BUILD ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      extendBody: true,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  _buildSearchBar(),
                  const SizedBox(height: 14),
                  _buildQuickActions(),
                  const SizedBox(height: 28),
                  _buildResultsSection(),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(35)),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Location',
                          style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: Colors.white, fontFamily: 'Outfit',
                            letterSpacing: -0.4, height: 1.1,
                          )),
                        const SizedBox(height: 2),
                        Text('Find mess services near you',
                          style: TextStyle(
                            fontSize: 13, color: Colors.white.withAlpha(155),
                            fontFamily: 'Outfit',
                          )),
                      ],
                    ),
                  ),
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEC5B13), Color(0xFFE85D19)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            // Curved bottom transition
            Container(
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F2EE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    final focused = _focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: focused
                ? AppTheme.primary.withAlpha(55)
                : Colors.black.withAlpha(18),
            blurRadius: focused ? 22 : 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: focused ? AppTheme.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500,
          color: Color(0xFF0F172A), fontFamily: 'Outfit',
        ),
        decoration: InputDecoration(
          hintText: 'Search area, locality, pincode...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8), fontSize: 14, fontFamily: 'Outfit',
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(13),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isSearching
                  ? SizedBox(
                      key: const ValueKey('spin'),
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: AppTheme.primary))
                  : Icon(Icons.search_rounded,
                      key: const ValueKey('icon'),
                      color: focused ? AppTheme.primary : const Color(0xFF94A3B8),
                      size: 22),
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Color(0xFF94A3B8), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        ),
      ),
    );
  }

  // ─── Quick Actions ───────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: _isDetectingLocation ? Icons.my_location_rounded : Icons.near_me_rounded,
            label: _isDetectingLocation ? 'Detecting...' : 'Use Current Location',
            isPrimary: true,
            isLoading: _isDetectingLocation,
            onTap: _handleCurrentLocation,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.map_outlined,
            label: 'Select from Map',
            isPrimary: false,
            onTap: _handleSelectFromMap,
          ),
        ),
      ],
    );
  }

  // ─── Results ─────────────────────────────────────────────────────────────────
  Widget _buildResultsSection() {
    if (_searchResults.isNotEmpty || _searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }
    return _buildDefaultSuggestions();
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && !_isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.search_off_rounded, size: 34, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 14),
              const Text('No locations found',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A), fontFamily: 'Outfit')),
              const SizedBox(height: 5),
              const Text('Try a different area name or pincode',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Outfit')),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('SEARCH RESULTS', badge: '${_searchResults.length}'),
        const SizedBox(height: 12),
        ...List.generate(_searchResults.length, (i) {
          final r = _searchResults[i];
          return _animatedItem(i, Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LocationCard(
              icon: Icons.location_on_rounded,
              title: r['name'] ?? r['area'] ?? '',
              subtitle: r['area'] ?? '',
              accentColor: AppTheme.primary,
              onTap: () => _handleSearchResultTap(r),
            ),
          ));
        }),
      ],
    );
  }

  Widget _buildDefaultSuggestions() {
    // ── Loading state ─────────────────────────────────────────────────────────
    if (_loadingSuggestions) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('PICKUP HUBS'),
          const SizedBox(height: 12),
          ...List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(10),
                      blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 12, width: 140,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            )),
                        const SizedBox(height: 7),
                        Container(height: 10, width: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      );
    }

    // ── Empty state (admin hasn't added any hubs yet) ─────────────────────────
    if (_pickupSuggestions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('PICKUP HUBS'),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.store_mall_directory_outlined,
                      size: 30, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 12),
                const Text('No hubs added yet',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A), fontFamily: 'Outfit')),
                const SizedBox(height: 4),
                const Text('The admin hasn\'t added any pickup hubs yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B),
                    fontFamily: 'Outfit')),
              ],
            ),
          ),
        ],
      );
    }

    // ── Real data from backend ────────────────────────────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('PICKUP HUBS', badge: '${_pickupSuggestions.length}'),
        const SizedBox(height: 12),
        ...List.generate(_pickupSuggestions.length, (i) {
          final s = _pickupSuggestions[i];
          // Cycle through a palette of accent colours
          const colors = [
            Color(0xFFEC5B13),
            Color(0xFF7C3AED),
            Color(0xFF0284C7),
            Color(0xFF059669),
            Color(0xFFD97706),
          ];
          final accent = colors[i % colors.length];
          return _animatedItem(i, Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _LocationCard(
              icon: Icons.storefront_rounded,
              title: s['name']! as String,
              subtitle: s['area']! as String,
              tag: 'Hub',
              accentColor: accent,
              onTap: () => _showMapBottomSheet(
                name: s['name']! as String,
                address: s['address']! as String,
                area: s['area']! as String,
                position: LatLng(s['lat'] as double, s['lon'] as double),
              ),
            ),
          ));
        }),
      ],
    );
  }


  Widget _animatedItem(int i, Widget child) {
    return AnimatedBuilder(
      animation: _listController,
      builder: (_, c) {
        final t = ((_listController.value - i * 0.1) / 0.7).clamp(0.0, 1.0);
        final c2 = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: c2,
          child: Transform.translate(offset: Offset(0, 20 * (1 - c2)), child: c),
        );
      },
      child: child,
    );
  }

  Widget _sectionLabel(String label, {String? badge}) {
    return Row(
      children: [
        Text(label,
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w800,
            color: Color(0xFF64748B), fontFamily: 'Outfit', letterSpacing: 1.4,
          )),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark, fontFamily: 'Outfit')),
          ),
        ],
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
      ],
    );
  }
}

// ─── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon, required this.label,
    required this.isPrimary, required this.onTap,
    this.isLoading = false,
  });
  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          gradient: widget.isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFFEC5B13), Color(0xFFE85D19)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: widget.isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: widget.isPrimary
              ? null
              : Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: widget.isPrimary
                  ? AppTheme.primary.withAlpha(_pressed ? 45 : 75)
                  : Colors.black.withAlpha(_pressed ? 8 : 16),
              blurRadius: _pressed ? 6 : 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.isLoading
                ? SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.isPrimary ? Colors.white : AppTheme.primary,
                    ))
                : Icon(widget.icon, size: 16,
                    color: widget.isPrimary ? Colors.white : AppTheme.primary),
            const SizedBox(width: 7),
            Flexible(
              child: Text(widget.label,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: widget.isPrimary ? Colors.white : const Color(0xFF0F172A),
                  fontFamily: 'Outfit',
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location Card ─────────────────────────────────────────────────────────────
class _LocationCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? tag;
  final Color accentColor;
  final VoidCallback onTap;
  const _LocationCard({
    required this.icon, required this.title, required this.subtitle,
    required this.accentColor, required this.onTap, this.tag,
  });
  @override
  State<_LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<_LocationCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(_pressed ? 6 : 14),
              blurRadius: _pressed ? 6 : 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: widget.accentColor.withAlpha(22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(widget.title,
                            style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A), fontFamily: 'Outfit',
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (widget.tag != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(widget.tag!,
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w800,
                                color: widget.accentColor, fontFamily: 'Outfit',
                              )),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(widget.subtitle,
                      style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Outfit',
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
