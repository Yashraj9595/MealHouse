import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/core/services/location_service.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/features/mess_owner/presentation/providers/mess_registration_provider.dart';

class MessLocationScreen extends ConsumerStatefulWidget {
  final MessModel? initialMess;
  const MessLocationScreen({super.key, this.initialMess});

  @override
  ConsumerState<MessLocationScreen> createState() => _MessLocationScreenState();
}

class _MessLocationScreenState extends ConsumerState<MessLocationScreen> {
  static const Color _blueColor = Color(0xFFE8650A); // Changed to match theme primary
  static const Color _borderColor = Color(0xFFDEDEDE);

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();

  // Draggable pin offset within the map area
  Offset _pinOffset = const Offset(0, 0);
  bool _pinInitialized = false;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isSaving = false;
  final MessRepository _messRepository = sl<MessRepository>();

  @override
  void initState() {
    super.initState();
    if (widget.initialMess != null) {
      _latitude = widget.initialMess!.latitude;
      _longitude = widget.initialMess!.longitude;
      
      // Try to parse address
      final addressParts = widget.initialMess!.address.split(',');
      if (addressParts.isNotEmpty) _streetController.text = addressParts[0].trim();
      if (addressParts.length > 1) _cityController.text = addressParts[1].trim();
      if (addressParts.length > 2) _postalController.text = addressParts[2].trim();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _onUseCurrentLocation() async {
    final locationService = sl<LocationService>();
    final position = await locationService.getCurrentPosition();
    
    if (position != null) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      
      final placemark = await locationService.getAddressFromLatLng(position);
      if (placemark != null) {
        setState(() {
          // Use name for street, but don't include the full address display name here
          _streetController.text = placemark.name ?? placemark.thoroughfare ?? '';
          
          // Fallback logic for City
          _cityController.text = placemark.locality ?? 
                                placemark.subAdministrativeArea ?? 
                                placemark.administrativeArea ?? '';
          
          _postalController.text = placemark.postalCode ?? '';
          
          // Final fallback to make sure something is shown
          if (_streetController.text.isEmpty && placemark.subLocality != null) {
            _streetController.text = placemark.subLocality!;
          }
          if (_cityController.text.isEmpty && placemark.subLocality != null) {
             _cityController.text = placemark.subLocality!;
          }
        });
      }
    }
  }

  Future<void> _onConfirmLocation() async {
    final address = '${_streetController.text}, ${_cityController.text}, ${_postalController.text}';
    
    if (widget.initialMess != null) {
      // Edit mode
      setState(() => _isSaving = true);
      try {
        await _messRepository.updateMess(widget.initialMess!.id!, {
          'address': address,
          'latitude': _latitude,
          'longitude': _longitude,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location updated successfully!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update location: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    } else {
      // Registration mode
      ref.read(messRegistrationProvider.notifier).updateLocation(
        address: address,
        latitude: _latitude,
        longitude: _longitude,
      );
      Navigator.pushNamed(context, AppRoutes.operatingHoursScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 560 : double.infinity,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: _buildStepIndicator(),
                          ),
                          // Search bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildSearchBar(),
                          ),
                          const SizedBox(height: 12),
                          // Use My Current Location button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildCurrentLocationButton(),
                          ),
                          const SizedBox(height: 12),
                          // Map view
                          _buildMapView(),
                          // Confirm address section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            child: _buildConfirmAddressSection(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  // Confirm Location button
                  _buildConfirmButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          alignment: Alignment.center,
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A2E),
            size: 20,
          ),
        ),
      ),
      title: Text(
        'Mess Location',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
          letterSpacing: -0.2,
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step 4 of 4',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            Text(
              'Final Step',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _blueColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 1.0,
            minHeight: 5,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(_blueColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: 'Search for your building or area...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF9E9E9E),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF9E9E9E),
            size: 22,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return GestureDetector(
      onTap: _onUseCurrentLocation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_pin, color: _blueColor, size: 22),
            const SizedBox(width: 8),
            Text(
              'Use My Current Location',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _blueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        const mapHeight = 220.0;

        if (!_pinInitialized) {
          _pinOffset = Offset(mapWidth / 2, mapHeight / 2 - 10);
          _pinInitialized = true;
        }

        return SizedBox(
          width: mapWidth,
          height: mapHeight,
          child: Stack(
            children: [
              // Map background image
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1526778545894-62d46c29bd11?w=1000&q=80',
                  fit: BoxFit.cover,
                  semanticLabel:
                      'Detailed city map showing streets, blocks, and landmarks',
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFF0F0F0),
                    child: const Center(
                      child: Icon(Icons.map_outlined, size: 64, color: Color(0xFFCCCCCC)),
                    ),
                  ),
                ),
              ),
              // Draggable pin with shadow
              Positioned(
                left: _pinOffset.dx - 18,
                top: _pinOffset.dy - 36,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      double newX = _pinOffset.dx + details.delta.dx;
                      double newY = _pinOffset.dy + details.delta.dy;
                      newX = newX.clamp(18.0, mapWidth - 18);
                      newY = newY.clamp(36.0, mapHeight.toDouble());
                      _pinOffset = Offset(newX, newY);
                    });
                  },
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 12,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
                        size: 42,
                      ),
                    ],
                  ),
                ),
              ),
              // "Drag to adjust" tooltip
              Positioned(
                left: _pinOffset.dx - 60,
                top: _pinOffset.dy - 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Drag to adjust',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONFIRM ADDRESS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF9E9E9E),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        // Street Address
        Text(
          'Street Address',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField(controller: _streetController),
        const SizedBox(height: 16),
        // City and Postal Code row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(controller: _cityController),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Postal Code',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _postalController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Latitude and Longitude row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Latitude',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: TextEditingController(text: _latitude.toStringAsFixed(6)),
                    readOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Longitude',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: TextEditingController(text: _longitude.toStringAsFixed(6)),
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF0F0F0) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFF1A1A2E),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }


  Widget _buildConfirmButton() {
    final isLoading = _isSaving;
    final isEditMode = widget.initialMess != null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : _onConfirmLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blueColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditMode ? 'Save Changes' : 'Confirm Location',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
