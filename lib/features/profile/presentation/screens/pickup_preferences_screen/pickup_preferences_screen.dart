import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/auth/domain/repositories/auth_repository.dart';
import 'package:meal_house/features/auth/domain/entities/user.dart';

class PickupPreferencesScreen extends StatefulWidget {
  const PickupPreferencesScreen({super.key});

  @override
  State<PickupPreferencesScreen> createState() =>
      _PickupPreferencesScreenState();
}

class _PickupPreferencesScreenState extends State<PickupPreferencesScreen> {
  static const _primaryOrange = Color(0xFFE85D19);
  static const _bgColor = Color(0xFFF5F5F5);
  static const _darkNavy = Color(0xFF1A2340);

  final AuthRepository _authRepository = sl<AuthRepository>();
  PickupPreferences? _preferences;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _pushNotifications = true;
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
          _preferences = user.pickupPreferences ?? const PickupPreferences();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load preferences')),
        );
      }
    }
  }

  Future<void> _saveAllChanges() async {
    setState(() => _isSaving = true);
    try {
      await _authRepository.updateProfile(
        pickupPreferences: _preferences,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMapSection(),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDailyScheduleHeader(),
                          SizedBox(height: 1.5.h),
                          _buildPickupCard(
                            icon: Icons.coffee_rounded,
                            title: 'Breakfast Pickup',
                            location: _preferences?.breakfast ?? 'Not Set',
                            time: '08:30 AM',
                            onEdit: () => _showLocationSelector('breakfast'),
                          ),
                          SizedBox(height: 1.5.h),
                          _buildPickupCard(
                            icon: Icons.wb_sunny_rounded,
                            title: 'Lunch Pickup',
                            location: _preferences?.lunch ?? 'Not Set',
                            time: '12:45 PM',
                            onEdit: () => _showLocationSelector('lunch'),
                          ),
                          SizedBox(height: 1.5.h),
                          _buildPickupCard(
                            icon: Icons.nightlight_round,
                            title: 'Dinner Pickup',
                            location: _preferences?.dinner ?? 'Not Set',
                            time: '07:30 PM',
                            onEdit: () => _showLocationSelector('dinner'),
                          ),
                          SizedBox(height: 2.5.h),
                          _buildSettingsSection(),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
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
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Pickup Preferences',
              style: GoogleFonts.dmSans(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.black87, size: 24),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      width: double.infinity,
      height: 22.h,
      color: Colors.white,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFF0EFE9),
            child: CustomPaint(painter: _MapGridPainter()),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: [
                Icon(Icons.location_on, color: _primaryOrange, size: 22),
                SizedBox(width: 1.w),
                Text(
                  'Active Pickup Zone: Pune',
                  style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyScheduleHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daily Schedule',
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
          decoration: BoxDecoration(
            color: _primaryOrange.withAlpha(25),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: _primaryOrange.withAlpha(80), width: 1),
          ),
          child: Text(
            'CURRENT PLAN',
            style: GoogleFonts.dmSans(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: _primaryOrange,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupCard({
    required IconData icon,
    required String title,
    required String location,
    required String time,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _primaryOrange.withAlpha(25),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: _primaryOrange, size: 24),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  location,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 0.2.h),
                Text(
                  'Scheduled for $time',
                  style: GoogleFonts.dmSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: _primaryOrange,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'Edit',
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SETTINGS',
          style: GoogleFonts.dmSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black45,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(30),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Push Notifications',
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Switch(
                      value: _pushNotifications,
                      onChanged: (val) =>
                          setState(() => _pushNotifications = val),
                      activeThumbColor: Colors.white,
                      activeTrackColor: _primaryOrange,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.withAlpha(80),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.withAlpha(30), indent: 16, endIndent: 16),
              InkWell(
                onTap: () {},
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14.0),
                  bottomRight: Radius.circular(14.0),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(30),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Icon(Icons.access_time_rounded, color: Colors.black54, size: 20),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Weekend Schedule',
                          style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveAllChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: _darkNavy,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 1.8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            elevation: 0,
          ),
          child: _isSaving 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                'Save All Changes',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
        ),
      ),
    );
  }

  void _showLocationSelector(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Pickup Location for $type',
              style: GoogleFonts.dmSans(fontSize: 15.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 2.h),
            if (_user?.savedLocations == null || _user!.savedLocations!.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Center(
                  child: Text(
                    'No saved locations found. Please add some first.',
                    style: GoogleFonts.dmSans(color: Colors.black54),
                  ),
                ),
              )
            else
              ..._user!.savedLocations!.map((loc) => ListTile(
                leading: Icon(Icons.location_on, color: _primaryOrange),
                title: Text(loc.label),
                subtitle: Text(loc.address),
                onTap: () {
                  setState(() {
                    if (type == 'breakfast') {
                      _preferences = PickupPreferences(
                        breakfast: loc.address,
                        lunch: _preferences?.lunch,
                        dinner: _preferences?.dinner,
                      );
                    } else if (type == 'lunch') {
                      _preferences = PickupPreferences(
                        breakfast: _preferences?.breakfast,
                        lunch: loc.address,
                        dinner: _preferences?.dinner,
                      );
                    } else if (type == 'dinner') {
                      _preferences = PickupPreferences(
                        breakfast: _preferences?.breakfast,
                        lunch: _preferences?.lunch,
                        dinner: loc.address,
                      );
                    }
                  });
                  Navigator.of(ctx).pop();
                },
              )),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDDDD0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double cellW = size.width / 6;
    final double cellH = size.height / 5;

    for (int i = 0; i <= 6; i++) {
      canvas.drawLine(Offset(i * cellW, 0), Offset(i * cellW, size.height), paint);
    }
    for (int j = 0; j <= 5; j++) {
      canvas.drawLine(Offset(0, j * cellH), Offset(size.width, j * cellH), paint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFFCCCCC0)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width * 0.1, 0), Offset(0, size.height * 0.3), roadPaint);
    canvas.drawLine(Offset(size.width * 0.9, 0), Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width * 0.3, size.height), roadPaint);
    canvas.drawLine(Offset(size.width, size.height * 0.6), Offset(size.width * 0.7, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
