import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:sizer/sizer.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/auth/domain/repositories/auth_repository.dart';
import 'package:meal_house/features/auth/domain/entities/user.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  static const _primaryOrange = Color(0xFFE85D19);
  static const _bgColor = Color(0xFFF5F5F5);

  final AuthRepository _authRepository = sl<AuthRepository>();
  List<SavedLocation> _locations = [];
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _locations = List.from(user.savedLocations ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load locations')),
        );
      }
    }
  }

  Future<void> _saveToBackend() async {
    try {
      await _authRepository.updateProfile(
        savedLocations: _locations,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: _primaryOrange))
                : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAddLocationButton(),
                    SizedBox(height: 2.5.h),
                    Text(
                      'YOUR PLACES',
                      style: GoogleFonts.dmSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: _primaryOrange,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    if (_locations.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: Text(
                            'No saved locations yet',
                            style: GoogleFonts.dmSans(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_locations.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 1.5.h),
                          child: _buildLocationCard(_locations[index], index),
                        );
                      }),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 24,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Saved Locations',
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildAddLocationButton() {
    return GestureDetector(
      onTap: () => _showAddLocationDialog(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: _primaryOrange,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_location_alt_rounded,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Add New Location',
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(SavedLocation location, int index) {
    IconData getIcon(String? iconName) {
      switch (iconName) {
        case 'Home': return Icons.home_rounded;
        case 'Work': return Icons.work_rounded;
        case 'Pickup': return Icons.local_shipping_rounded;
        default: return Icons.location_on_rounded;
      }
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      getIcon(location.icon),
                      color: _primaryOrange,
                      size: 22,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      location.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.8.h),
                Text(
                  location.address,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.5.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditLocationDialog(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryOrange.withAlpha(25),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_rounded,
                              color: _primaryOrange,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Edit',
                              style: GoogleFonts.dmSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: _primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: () => _confirmDelete(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(30),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.black54,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Delete',
                              style: GoogleFonts.dmSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 3.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: 90,
              height: 90,
              color: const Color(0xFFE8F5E9),
              child: const Icon(Icons.map_outlined, color: Colors.green, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.explore_outlined, 'Explore', false),
              _buildNavItem(Icons.bookmark_rounded, 'Saved', true),
              _buildNavItem(Icons.history_rounded, 'Activity', false),
              _buildNavItem(
                Icons.person_outline_rounded,
                'Profile',
                false,
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.profileScreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? _primaryOrange : Colors.grey, size: 24),
          SizedBox(height: 0.3.h),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? _primaryOrange : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditLocationDialog(int index) {
    final location = _locations[index];
    final labelController = TextEditingController(text: location.label);
    final addressController = TextEditingController(text: location.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(80),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Edit Location',
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              _buildDialogField('Location Name', labelController, 'e.g. Home, Office'),
              SizedBox(height: 1.5.h),
              _buildDialogField('Pickup Address', addressController, 'Enter pickup address', icon: Icons.location_on_outlined),
              SizedBox(height: 2.5.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newLabel = labelController.text.trim();
                    final newAddress = addressController.text.trim();
                    if (newLabel.isEmpty || newAddress.isEmpty) return;

                    setState(() {
                      _locations[index] = SavedLocation(
                        label: newLabel,
                        address: newAddress,
                        icon: location.icon,
                      );
                    });

                    await _saveToBackend();
                    if (mounted) Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text('Save Location', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLocationDialog() {
    final labelController = TextEditingController();
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(80),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Add New Location',
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              _buildDialogField('Location Name', labelController, 'e.g. Home, Office'),
              SizedBox(height: 1.5.h),
              _buildDialogField('Pickup Address', addressController, 'Enter pickup address', icon: Icons.location_on_outlined),
              SizedBox(height: 2.5.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newLabel = labelController.text.trim();
                    final newAddress = addressController.text.trim();
                    if (newLabel.isEmpty || newAddress.isEmpty) return;

                    setState(() {
                      _locations.add(SavedLocation(
                        label: newLabel,
                        address: newAddress,
                        icon: 'Pickup',
                      ));
                    });

                    await _saveToBackend();
                    if (mounted) Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text('Add Location', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, String hint, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 0.8.h),
        TextField(
          controller: controller,
          style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(color: Colors.black38, fontSize: 12.sp),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            prefixIcon: icon != null ? Icon(icon, color: _primaryOrange, size: 20) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Remove Location', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to remove "${_locations[index].label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _locations.removeAt(index));
              await _saveToBackend();
              if (mounted) Navigator.of(ctx).pop();
            },
            child: Text('Remove', style: GoogleFonts.dmSans(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
