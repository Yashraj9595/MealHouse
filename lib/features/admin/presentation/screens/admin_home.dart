import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/admin/presentation/screens/admin_profile_screen.dart';
import 'package:meal_house/features/admin/presentation/screens/pickup_points/pickup_points_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _AdminDashboardSubScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surface,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.grid_view_rounded),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.grid_view_rounded),
              ),
              label: 'Console',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.admin_panel_settings_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.admin_panel_settings_rounded),
              ),
              label: 'Security',
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardSubScreen extends StatelessWidget {
  const _AdminDashboardSubScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Command Center',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Users',
                    '1,254',
                    Icons.people_alt_rounded,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Messes',
                    '48',
                    Icons.restaurant_rounded,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              context,
              'Pending Approvals',
              '12 Vendors waiting',
              Icons.pending_actions_rounded,
              Colors.green,
            ),
            const SizedBox(height: 32),
            Text(
              'LOGISTICS MANAGEMENT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMuted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              context,
              'Manage Pickup Points',
              'Configure fleet delivery locations',
              Icons.location_on_rounded,
              AppTheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PickupPointsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, Admin!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          'System Overview',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        value,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: value.length > 15 ? 14 : 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
