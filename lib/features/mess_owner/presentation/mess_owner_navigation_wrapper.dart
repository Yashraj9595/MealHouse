import 'package:flutter/material.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_profile/dashboard_screen/dashboard_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_orders/orders_screen/orders_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/menu/todays_menu_screen/todays_menu_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/earnings/earnings_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/profile/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/shared/notifications/tab_change_notification.dart';

class MessOwnerNavigationWrapper extends StatefulWidget {
  const MessOwnerNavigationWrapper({super.key});

  @override
  State<MessOwnerNavigationWrapper> createState() =>
      _MessOwnerNavigationWrapperState();
}

class _MessOwnerNavigationWrapperState
    extends State<MessOwnerNavigationWrapper> {
  int _selectedIndex = 0;
  String? _menuInitialTab;

  List<Widget> _getScreens() {
    return [
      const DashboardScreen(),
      const OrdersScreen(),
      TodaysMenuScreen(initialTab: _menuInitialTab),
      const EarningsScreen(),
      const MessOwnerProfileScreen(),
    ];
  }

  static const List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      'label': 'Dashboard',
    },
    {
      'icon': Icons.receipt_long_outlined,
      'activeIcon': Icons.receipt_long,
      'label': 'Orders',
    },
    {
      'icon': Icons.menu_book_outlined,
      'activeIcon': Icons.menu_book,
      'label': 'Menu',
    },
    {
      'icon': Icons.monetization_on_outlined,
      'activeIcon': Icons.monetization_on,
      'label': 'Earnings',
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Profile',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return NotificationListener<TabChangeNotification>(
      onNotification: (notification) {
        setState(() {
          _selectedIndex = notification.index;
          if (notification.index == 2 && notification.args is String) {
            _menuInitialTab = notification.args as String;
          }
        });
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF0E6), // Set global background for owner screens
        body: SafeArea(
          bottom: false, // Scaffold's bottomNavigationBar handles bottom safe area
          child: IndexedStack(
            index: _selectedIndex,
            children: _getScreens(),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_navItems.length, (index) {
                  final isActive = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive
                                ? _navItems[index]['activeIcon'] as IconData
                                : _navItems[index]['icon'] as IconData,
                            color: isActive
                                ? const Color(0xFFE8650A)
                                : const Color(0xFF9CA3AF),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _navItems[index]['label'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isActive
                                  ? const Color(0xFFE8650A)
                                  : const Color(0xFF9CA3AF),
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
        ),
      ),
    );
  }
}
