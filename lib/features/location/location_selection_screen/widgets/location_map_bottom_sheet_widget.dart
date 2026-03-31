import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/core/services/location_service.dart';
import 'package:meal_house/core/di/service_locator.dart';

class LocationMapBottomSheetWidget extends StatefulWidget {
  final String locationName;
  final String addressLine1;
  final String addressLine2;
  final LatLng? initialPosition;
  final Function(String name, String addressLine1, String addressLine2, LatLng position) onConfirm;

  const LocationMapBottomSheetWidget({
    super.key,
    required this.locationName,
    required this.addressLine1,
    required this.addressLine2,
    this.initialPosition,
    required this.onConfirm,
  });

  @override
  State<LocationMapBottomSheetWidget> createState() =>
      _LocationMapBottomSheetWidgetState();
}

class _LocationMapBottomSheetWidgetState
    extends State<LocationMapBottomSheetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pinController;
  late Animation<double> _pinBounce;
  late MapController _mapController;
  
  // Default to Pune (MIT Area) if no initial position is provided
  late LatLng _currentCenter;
  
  bool _isFetchingAddress = false;
  String _currentName = '';
  String _currentAddress = '';
  String _currentArea = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialPosition ?? const LatLng(18.518, 73.815);
    _currentName = widget.locationName;
    _currentAddress = widget.addressLine1;
    _currentArea = widget.addressLine2;
    
    _mapController = MapController();
    
    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pinBounce = Tween<double>(
      begin: 0,
      end: -15,
    ).animate(CurvedAnimation(parent: _pinController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _updateAddressFromLatLng(LatLng center) async {
    setState(() {
      _isFetchingAddress = true;
    });
    try {
      final locationService = sl<LocationService>();
      final position = Position(
        longitude: center.longitude,
        latitude: center.latitude,
        timestamp: DateTime.now(),
        accuracy: 100,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      final placemark = await locationService.getAddressFromLatLng(position);
      if (placemark != null) {
        if (mounted) {
          setState(() {
            _currentName = placemark.name ?? 'Selected Location';
            _currentAddress = locationService.formatAddress(placemark);
            
            final sub = placemark.subLocality ?? '';
            final loc = placemark.locality ?? '';
            final state = placemark.administrativeArea ?? '';
            final pin = placemark.postalCode ?? '';
            
            List<String> areaParts = [];
            if (sub.isNotEmpty) areaParts.add(sub);
            if (loc.isNotEmpty) areaParts.add(loc);
            if (state.isNotEmpty) areaParts.add(state);
            if (pin.isNotEmpty) areaParts.add(pin);
            
            _currentArea = areaParts.join(', ');
            _isFetchingAddress = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentName = 'Selected Location';
            _currentAddress = '${center.latitude}, ${center.longitude}';
            _currentArea = 'Lat: ${center.latitude.toStringAsFixed(4)}, Lng: ${center.longitude.toStringAsFixed(4)}';
            _isFetchingAddress = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingAddress = false;
        });
      }
    }
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      if (!_pinController.isAnimating && _pinController.isDismissed) {
        _pinController.forward();
      }

      _currentCenter = camera.center;

      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          _pinController.reverse();
          _updateAddressFromLatLng(_currentCenter);
        }
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    setState(() {
      _isFetchingAddress = true;
    });
    final locationService = sl<LocationService>();
    final position = await locationService.getCurrentPosition();
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      try {
        _mapController.move(latLng, 16.0);
      } catch (e) {
        debugPrint('MapController not ready: $e');
      }
      _updateAddressFromLatLng(latLng);
    } else {
      if (mounted) {
        setState(() {
          _isFetchingAddress = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get your location.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final sheetHeight = isTablet ? size.height * 0.75 : size.height * 0.88;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select location on Map',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.textSecondary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Map area
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: 15.0,
                    onPositionChanged: _onMapPositionChanged,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.mealhouse.app',
                    ),
                  ],
                ),
                // Animated pin targeting exact center
                Center(
                  child: AnimatedBuilder(
                    animation: _pinBounce,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _pinBounce.value),
                      child: child,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withAlpha(102),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        // Pin vertical stem visually connecting to center point (optional)
                        Container(
                          width: 3,
                          height: 12,
                          color: AppTheme.primary,
                        ),
                        // Pin shadow indicator exactly at center
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Get Current Location Button Overlay
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: 'map_current_location',
                    backgroundColor: Colors.white,
                    onPressed: _goToCurrentLocation,
                    child: const Icon(Icons.my_location, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
          // Selected address card
          _buildAddressCard(context),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryMuted, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SELECTED ADDRESS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDark,
                  fontFamily: 'Outfit',
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (_isFetchingAddress)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _currentAddress,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontFamily: 'Outfit',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            _currentArea,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              fontFamily: 'Outfit',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isFetchingAddress ? null : () {
                widget.onConfirm(_currentName, _currentAddress, _currentArea, _currentCenter);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: _isFetchingAddress ? null : AppTheme.primaryGradient,
                  color: _isFetchingAddress ? AppTheme.surfaceVariant : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: _isFetchingAddress ? AppTheme.textSecondary : Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _isFetchingAddress ? AppTheme.textSecondary : Colors.white,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
