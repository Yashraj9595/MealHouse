import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _orderUpdates = true;
  bool _autoReorderAlerts = true;
  bool _pickupReminders = true;
  bool _walletAlerts = true;
  bool _messAnnouncements = false;

  int _selectedNavIndex = 3; // Settings active

  static const Color _primaryOrange = Color(0xFFE85D19);
  static const Color _bgColor = Color(0xFFF5F5F5);
  static const Color _iconBg = Color(0xFFFAEDE5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('ORDER MANAGEMENT'),
                    SizedBox(height: 1.5.h),
                    _buildSettingItem(
                      icon: Icons.restaurant_menu,
                      title: 'Order Updates',
                      subtitle: 'Status tracking for your daily meals',
                      value: _orderUpdates,
                      onChanged: (v) => setState(() => _orderUpdates = v),
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.sync,
                      title: 'Auto Reorder Alerts',
                      subtitle: 'Confirmations for subscription plans',
                      value: _autoReorderAlerts,
                      onChanged: (v) => setState(() => _autoReorderAlerts = v),
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.alarm,
                      title: 'Pickup Reminders',
                      subtitle: "Don't miss your meal window",
                      value: _pickupReminders,
                      onChanged: (v) => setState(() => _pickupReminders = v),
                    ),
                    SizedBox(height: 3.h),
                    _buildSectionLabel('ACCOUNT & APP'),
                    SizedBox(height: 1.5.h),
                    _buildSettingItem(
                      icon: Icons.account_balance_wallet,
                      title: 'Wallet Alerts',
                      subtitle: 'Low balance and payment receipts',
                      value: _walletAlerts,
                      onChanged: (v) => setState(() => _walletAlerts = v),
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.campaign,
                      title: 'Mess Announcements',
                      subtitle: 'New menus and holiday schedules',
                      value: _messAnnouncements,
                      onChanged: (v) => setState(() => _messAnnouncements = v),
                    ),
                    SizedBox(height: 3.h),
                    _buildInfoCard(),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF1A1A1A),
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            'Notification Settings',
            style: GoogleFonts.dmSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: _primaryOrange,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
      indent: 72,
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: _primaryOrange, size: 26),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF888888),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _primaryOrange,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCCCCCC),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEDE5),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF5D5C5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primaryOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info, color: Colors.white, size: 20),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need a quiet hour?',
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'You can temporarily silence all notifications from your system settings.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 1.h),
                GestureDetector(
                  onTap: () {
                    // Open system settings - graceful no-op on web
                  },
                  child: Text(
                    'System Settings →',
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'HOME'},
      {'icon': Icons.receipt_long_outlined, 'label': 'ORDERS'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'WALLET'},
      {'icon': Icons.settings, 'label': 'SETTINGS'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final isActive = index == _selectedNavIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedNavIndex = index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[index]['icon'] as IconData,
                        color: isActive
                            ? const Color(0xFFE85D19)
                            : const Color(0xFF888888),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFFE85D19)
                              : const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
