import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meal_house/core/app_export.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meal_house/core/services/location_service.dart';
import 'package:meal_house/features/pickup_points/data/services/pickup_service.dart';
import './widgets/pickup_confirm_bar_widget.dart';
import 'package:meal_house/core/constants/meal_enum.dart';


class PickupPointSelectionScreen extends StatefulWidget {
  const PickupPointSelectionScreen({super.key});
  @override
  State<PickupPointSelectionScreen> createState() => _PickupPointSelectionScreenState();
}

class _PickupPointSelectionScreenState extends State<PickupPointSelectionScreen>
    with SingleTickerProviderStateMixin {
  MealType _selectedMeal = MealType.lunch;
  int _selectedPickupIndex = 0;

  bool _showMap = true;
  late AnimationController _listController;
  late MapController _mapController;

  double? _userLat;
  double? _userLon;
  String _userAddress = '';

  List<Map<String, dynamic>> _hubs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && _userLat == null) {
      final lat = args['lat'] as double?;
      final lon = args['lon'] as double?;
      if (lat != null && lon != null) {
        _userLat = lat;
        _userLon = lon;
        _userAddress = args['address'] as String? ?? '';
        _fetchPickupPoints();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mapController.move(LatLng(lat, lon), 14.0);
        });
      } else {
        _fetchPickupPoints();
      }
    } else if (_userLat == null) {
      _fetchPickupPoints();
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  // ── Map MongoDB doc → hub map ────────────────────────────────────────────────
  Map<String, dynamic> _mapDoc(Map<String, dynamic> doc) {
    final coords = doc['location']?['coordinates'];
    final double lat =
        coords is List && coords.length >= 2 ? (coords[1] as num).toDouble() : 0.0;
    final double lon =
        coords is List && coords.length >= 2 ? (coords[0] as num).toDouble() : 0.0;

    String slot(String meal) {
      final h = doc['operatingHours']?[meal];
      if (h == null) return '';
      final s = h['startTime'] ?? '';
      final e = h['endTime'] ?? '';
      return (s.isEmpty && e.isEmpty) ? '' : '$s - $e';
    }

    return {
      'id':             doc['_id']?.toString() ?? '',
      'name':           doc['name'] as String? ?? 'Pickup Point',
      'address':        doc['address'] as String? ?? '',
      'lat':            lat,
      'lon':            lon,
      'availableSlots': '${(doc['maxOrders'] as num?)?.toInt() ?? 50}',
      'rating':         '—',
      'instructions':   doc['instructions'] as String? ?? '',
      'breakfast':      {'timeSlot': slot('breakfast'), 'isActive': doc['operatingHours']?['breakfast']?['isActive'] == true},
      'lunch':          {'timeSlot': slot('lunch'), 'isActive': doc['operatingHours']?['lunch']?['isActive'] == true},
      'dinner':         {'timeSlot': slot('dinner'), 'isActive': doc['operatingHours']?['dinner']?['isActive'] == true},
    };
  }

  Future<void> _fetchPickupPoints() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final service = sl<PickupService>();
      final response = _userLat != null && _userLon != null
          ? await service.getNearbyPickupPoints(_userLat!, _userLon!)
          : await service.getAllPickupPoints();

      final List raw = (response.data?['data']?['pickupPoints'] as List?) ?? [];
      final hubs = raw.map((e) => _mapDoc(Map<String, dynamic>.from(e as Map))).toList();

      if (mounted) {
        setState(() { _hubs = hubs; _selectedPickupIndex = 0; _isLoading = false; });
        _listController.reset();
        _listController.forward();
        if (_showMap && hubs.isNotEmpty) {
          // Delaying slightly to ensure FlutterMap is rendered after _isLoading becomes false
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _showMap) {
              try {
                _mapController.move(
                  LatLng(hubs[0]['lat'] as double, hubs[0]['lon'] as double), 14.0);
              } catch (e) {
                debugPrint('Map not ready yet: $e');
              }
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load pickup points.\nPlease check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  String _formatDistance(double m) {
    if (m < 1000) return '${m.round()} m';
    return '${(m / 1000).toStringAsFixed(1)} km';
  }

  void _onMealChanged(MealType meal) {
    setState(() {
      _selectedMeal = meal;
      _selectedPickupIndex = 0;
    });
    // Move map to first available for new meal
    final available = _currentPickups;
    if (_showMap && available.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(
              LatLng(available[0]['lat'] as double, available[0]['lon'] as double),
              14.0);
        }
      });
    }
  }

  void _onPickupSelected(int index) {
    setState(() => _selectedPickupIndex = index);
    final current = _currentPickups;
    if (_showMap && current.isNotEmpty && index < current.length) {
      final hub = current[index];
      _mapController.move(
          LatLng(hub['lat'] as double, hub['lon'] as double), 15.5);
    }
  }

  List<Map<String, dynamic>> get _currentPickups {
    final mealStr = _selectedMeal.name; // 'breakfast', 'lunch', 'dinner'
    return _hubs.where((h) {
      final slots = h['slots'] as Map<String, dynamic>?;
      if (slots == null) return false;
      final mealSlot = slots[mealStr] as Map<String, dynamic>?;
      return mealSlot?['isActive'] == true;
    }).toList();
  }
  Map<String, dynamic>? get _selectedHub =>
      _currentPickups.isNotEmpty ? _currentPickups[_selectedPickupIndex] : null;

  void _handleConfirm() {
    final hub = _selectedHub;
    if (hub == null) return;
    
    // Save to global location state
    sl<LocationService>().updateLocation(
      hub['name'] as String,
      forMeal: _selectedMeal,
      position: Position(
        latitude: hub['lat'] as double,
        longitude: hub['lon'] as double,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ),
    );

    final mealLabel = _selectedMeal.name[0].toUpperCase() + _selectedMeal.name.substring(1);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$mealLabel pickup confirmed at ${hub['name']}!',
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500)),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    ));

    // Return to root (Home)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }


  IconData _getMealIcon(MealType meal) {
    switch (meal) {
      case MealType.breakfast: return Icons.breakfast_dining_rounded;
      case MealType.lunch:     return Icons.lunch_dining_rounded;
      case MealType.dinner:    return Icons.dinner_dining_rounded;
    }
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
          Expanded(child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
              ? _buildErrorState()
              : _currentPickups.isEmpty
                ? _buildEmptyState()
                : _buildBody()),
        ],
      ),

    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final mealLabel = _selectedMeal.name[0].toUpperCase() + _selectedMeal.name.substring(1);
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
                        const Text('Pickup Points',
                          style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w800,
                            color: Colors.white, fontFamily: 'Outfit',
                            letterSpacing: -0.4, height: 1.1,
                          )),
                        if (_userAddress.isNotEmpty)
                          Text(_userAddress,
                            style: TextStyle(
                              fontSize: 12, color: Colors.white.withAlpha(155),
                              fontFamily: 'Outfit',
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  // Map/list toggle
                  GestureDetector(
                    onTap: () => setState(() => _showMap = !_showMap),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: Icon(
                        _showMap ? Icons.list_rounded : Icons.map_rounded,
                        color: Colors.white, size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Selected meal pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEC5B13), Color(0xFFE85D19)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getMealIcon(_selectedMeal), color: Colors.white, size: 13),
                        const SizedBox(width: 5),
                        Text(mealLabel,
                          style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: Colors.white, fontFamily: 'Outfit',
                          )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Meal tabs
            _buildMealTabs(),
            // Curved bottom
            Container(
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F2EE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTabs() {
    final meals = [MealType.breakfast, MealType.lunch, MealType.dinner];
    final labels = ['Breakfast', 'Lunch', 'Dinner'];
    final icons = [
      Icons.breakfast_dining_rounded,
      Icons.lunch_dining_rounded,
      Icons.dinner_dining_rounded,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Row(
          children: List.generate(meals.length, (i) {
            final isSelected = _selectedMeal == meals[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => _onMealChanged(meals[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFEC5B13), Color(0xFFE85D19)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight)
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [BoxShadow(
                            color: AppTheme.primary.withAlpha(80),
                            blurRadius: 8, offset: const Offset(0, 3))]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icons[i], size: 13,
                          color: isSelected ? Colors.white : Colors.white.withAlpha(150)),
                      const SizedBox(width: 5),
                      Text(labels[i],
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.white.withAlpha(150),
                          fontFamily: 'Outfit',
                        )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── Empty / Error states ────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.location_off_rounded, size: 40,
                  color: AppTheme.primary.withAlpha(160)),
            ),
            const SizedBox(height: 20),
            const Text('No Pickup Points Nearby',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A), fontFamily: 'Outfit')),
            const SizedBox(height: 8),
            const Text(
              'The admin hasn\'t added any active\npickup points near your location yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B),
                fontFamily: 'Outfit', height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.error.withAlpha(15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.cloud_off_rounded, size: 40,
                  color: AppTheme.error.withAlpha(180)),
            ),
            const SizedBox(height: 20),
            Text(_error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A), fontFamily: 'Outfit')),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _fetchPickupPoints,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC5B13), Color(0xFFE85D19)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(80),
                      blurRadius: 14, offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Try Again',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: Colors.white, fontFamily: 'Outfit')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Body (map or list) ──────────────────────────────────────────────────────
  Widget _buildBody() {
    return _showMap ? _buildMapView() : _buildListView();
  }

  Widget _buildMapView() {
    final userLatLng = _userLat != null && _userLon != null
        ? LatLng(_userLat!, _userLon!)
        : const LatLng(18.518, 73.815);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userLatLng,
                  initialZoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.mealhouse.app',
                  ),
                  if (_userLat != null)
                    CircleLayer(circles: [
                      CircleMarker(
                        point: userLatLng,
                        radius: 10,
                        color: AppTheme.primary.withAlpha(55),
                        borderStrokeWidth: 3,
                        borderColor: AppTheme.primary,
                      ),
                    ]),
                  MarkerLayer(
                    markers: List.generate(_currentPickups.length, (i) {
                      final hub = _currentPickups[i];
                      final isSelected = i == _selectedPickupIndex;
                      return Marker(
                        point: LatLng(hub['lat'] as double, hub['lon'] as double),
                        width: isSelected ? 180 : 46,
                        height: isSelected ? 60 : 46,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _onPickupSelected(i),
                          child: isSelected
                              ? _buildSelectedMarker(hub)
                              : _buildNormalMarker(i + 1),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              // Hub count badge
              Positioned(
                top: 14, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(28),
                          blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEC5B13),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text('${_currentPickups.length} hubs found',
                        style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A), fontFamily: 'Outfit',
                        )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedHub != null) _buildSelectedHubCard(),
      ],
    );
  }

  Widget _buildSelectedMarker(Map<String, dynamic> hub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEC5B13), Color(0xFFE85D19)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: AppTheme.primary.withAlpha(120),
                  blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Text(hub['name'] as String,
            style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: Colors.white, fontFamily: 'Outfit',
            ),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Container(width: 2, height: 8, color: AppTheme.primary),
        Container(
          width: 12, height: 12,
          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget _buildNormalMarker(int number) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primary, width: 2.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(40),
              blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text('$number',
          style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: AppTheme.primary, fontFamily: 'Outfit',
          )),
      ),
    );
  }

  // ─── Selected hub bottom card in map view ────────────────────────────────────
  Widget _buildSelectedHubCard() {
    final hub = _selectedHub!;
    final slots = hub['slots'] as Map<String, dynamic>?;
    final timeSlot = (slots?[_selectedMeal.name]?['timeSlot'] as String?) ?? '';

    final dist = hub['_distanceM'] as double?;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20),
              blurRadius: 24, offset: const Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Numbered icon
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC5B13), Color(0xFFE85D19)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text('${_selectedPickupIndex + 1}',
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900,
                      color: Colors.white, fontFamily: 'Outfit',
                    )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hub['name'] as String,
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A), fontFamily: 'Outfit',
                      )),
                    const SizedBox(height: 2),
                    Text(hub['address'] as String,
                      style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Outfit',
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (dist != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_formatDistance(dist),
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800,
                      color: AppTheme.primaryDark, fontFamily: 'Outfit',
                    )),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Info chips
          Row(
            children: [
              if (timeSlot.isNotEmpty) _chip(Icons.access_time_rounded, timeSlot),
              if (timeSlot.isNotEmpty) const SizedBox(width: 8),
              _chip(Icons.chair_alt_rounded, '${hub['availableSlots']} slots'),
            ],
          ),
          const SizedBox(height: 16),
          // Confirm button
          GestureDetector(
            onTap: _handleConfirm,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEC5B13), Color(0xFFE85D19)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withAlpha(90),
                      blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Confirm Pickup Point',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: Colors.white, fontFamily: 'Outfit',
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primary),
          const SizedBox(width: 5),
          Text(label,
            style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: Color(0xFF475569), fontFamily: 'Outfit',
            )),
        ],
      ),
    );
  }

  // ─── List view ────────────────────────────────────────────────────────────────
  Widget _buildListView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Row(
                  children: [
                    const Text('NEARBY HUBS',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B), fontFamily: 'Outfit', letterSpacing: 1.4,
                      )),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${_currentPickups.length}',
                        style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark, fontFamily: 'Outfit',
                        )),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
                  ],
                ),
                const SizedBox(height: 14),
                ...List.generate(_currentPickups.length, (i) {
                  final hub = _currentPickups[i];
                  final slots = hub['slots'] as Map<String, dynamic>?;
                  final timeSlot = (slots?[_selectedMeal.name]?['timeSlot'] as String?) ?? '—';
                  final dist = hub['_distanceM'] as double?;
                  return AnimatedBuilder(
                    animation: _listController,
                    builder: (_, child) {
                      final t = ((_listController.value - i * 0.1) / 0.7).clamp(0.0, 1.0);
                      final c = Curves.easeOutCubic.transform(t);
                      return Opacity(
                        opacity: c,
                        child: Transform.translate(offset: Offset(0, 24 * (1 - c)), child: child),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _PickupCard(
                        index: i,
                        hub: hub,
                        timeSlot: timeSlot,
                        distance: dist != null ? _formatDistance(dist) : null,
                        isSelected: _selectedPickupIndex == i,
                        onTap: () => _onPickupSelected(i),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        PickupConfirmBarWidget(
          selectedPickup: _currentPickups.isNotEmpty
              ? {
                  'name': _currentPickups[_selectedPickupIndex]['name'] as String,
                  'distance': _currentPickups[_selectedPickupIndex]['_distanceM'] != null
                      ? _formatDistance(_currentPickups[_selectedPickupIndex]['_distanceM'] as double)
                      : '—',
                  'timeSlot': ((_currentPickups[_selectedPickupIndex]['slots']
                          as Map<String, dynamic>?)?[_selectedMeal.name]?['timeSlot'] as String?) ?? '',
                  'address': _currentPickups[_selectedPickupIndex]['address'] as String,
                  'rating': _currentPickups[_selectedPickupIndex]['rating'] as String,
                  'availableSlots': _currentPickups[_selectedPickupIndex]['availableSlots'] as String,
                }
              : null,
          selectedMeal: _selectedMeal,
          onConfirm: _handleConfirm,
        ),
      ],
    );
  }
}

// ─── Pickup Card ──────────────────────────────────────────────────────────────
class _PickupCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> hub;
  final String timeSlot;
  final String? distance;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickupCard({
    required this.index, required this.hub, required this.timeSlot,
    required this.distance, required this.isSelected, required this.onTap,
  });

  @override
  State<_PickupCard> createState() => _PickupCardState();
}

class _PickupCardState extends State<_PickupCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isSelected ? AppTheme.primary : Colors.transparent,
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? AppTheme.primary.withAlpha(28)
                  : Colors.black.withAlpha(14),
              blurRadius: widget.isSelected ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Number badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      gradient: widget.isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFEC5B13), Color(0xFFE85D19)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight)
                          : null,
                      color: widget.isSelected ? null : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text('${widget.index + 1}',
                        style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w900,
                          color: widget.isSelected ? Colors.white : const Color(0xFF94A3B8),
                          fontFamily: 'Outfit',
                        )),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.hub['name'] as String,
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: widget.isSelected
                                ? AppTheme.primary
                                : const Color(0xFF0F172A),
                            fontFamily: 'Outfit',
                          )),
                        const SizedBox(height: 2),
                        Text(widget.hub['address'] as String,
                          style: const TextStyle(
                            fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Outfit',
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (widget.distance != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(widget.distance!,
                        style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark, fontFamily: 'Outfit',
                        )),
                    ),
                  ],
                ],
              ),
              if (widget.timeSlot.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, size: 12,
                              color: AppTheme.primary),
                          const SizedBox(width: 5),
                          Text(widget.timeSlot,
                            style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: Color(0xFF475569), fontFamily: 'Outfit',
                            )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chair_alt_rounded, size: 12,
                              color: AppTheme.primary),
                          const SizedBox(width: 5),
                          Text('${widget.hub['availableSlots']} slots',
                            style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: Color(0xFF475569), fontFamily: 'Outfit',
                            )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
