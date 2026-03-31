import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:meal_house/core/router/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _primaryOrange = Color(0xFFE85D19);
  static const _bgColor = Color(0xFFF5F5F5);

  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(),
                    _buildDivider(),
                    _buildSectionLabel('ACCOUNT'),
                    _buildAccountSection(),
                    SizedBox(height: 2.h),
                    _buildSectionLabel('PREFERENCES'),
                    _buildPreferencesSection(),
                    SizedBox(height: 3.h),
                    _buildLogoutButton(),
                    SizedBox(height: 2.h),
                    _buildVersionText(),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
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
                'Settings',
                style: GoogleFonts.dmSans(
                  fontSize: 18.sp,
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

  Widget _buildProfileSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8C4B0), width: 3),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?w=200&h=200&fit=crop&crop=face',
                    fit: BoxFit.cover,
                    semanticLabel:
                        'Young man with short hair smiling, profile photo for Alex Thompson',
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFE8C4B0),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.editProfileScreen),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: _primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Alex Thompson',
            style: GoogleFonts.dmSans(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'alex.t@example.com',
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.grey.withAlpha(40));
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, top: 2.5.h, bottom: 1.h),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: _primaryOrange,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildSettingsRow(
            icon: Icons.notifications_outlined,
            title: 'Notification Settings',
            subtitle: 'Push, Email, and SMS',
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.notificationSettingsScreen),
          ),
          _buildRowDivider(),
          _buildSettingsRow(
            icon: Icons.lock_outline,
            title: 'Privacy Settings',
            subtitle: 'Manage your data visibility',
            onTap: () {},
          ),
          _buildRowDivider(),
          _buildSettingsRow(
            icon: Icons.lock_reset_outlined,
            title: 'Change Password',
            subtitle: 'Last changed 3 months ago',
            onTap: () {},
          ),
          _buildRowDivider(),
          _buildLanguageRow(),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _primaryOrange.withAlpha(20),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: _primaryOrange, size: 22),
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
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageRow() {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _primaryOrange.withAlpha(20),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Icon(
                Icons.language_outlined,
                color: _primaryOrange,
                size: 22,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language',
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    'System default',
                    style: GoogleFonts.dmSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: _primaryOrange, width: 1.2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'English',
                style: GoogleFonts.dmSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: _primaryOrange,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildRowDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 4.w,
      endIndent: 4.w,
      color: Colors.grey.withAlpha(30),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(30),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Icon(
                Icons.dark_mode_outlined,
                color: Colors.black54,
                size: 22,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Dark Mode',
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Switch(
              value: _darkMode,
              onChanged: (val) => setState(() => _darkMode = val),
              activeThumbColor: Colors.white,
              activeTrackColor: _primaryOrange,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.withAlpha(80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 1.8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: _primaryOrange, size: 22),
              SizedBox(width: 2.w),
              Text(
                'Logout',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _primaryOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionText() {
    return Center(
      child: Text(
        'Version 2.4.0 (Build 492)',
        style: GoogleFonts.dmSans(
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
          color: Colors.black38,
        ),
      ),
    );
  }
}
