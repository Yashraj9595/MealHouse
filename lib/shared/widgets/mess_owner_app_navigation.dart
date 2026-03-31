import 'package:flutter/material.dart';

import 'package:meal_house/core/theme/app_theme.dart';

/// Bottom navigation for mess-owner flows (e.g. pickup point orders).
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex.clamp(0, 4),
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_menu_outlined),
          selectedIcon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        NavigationDestination(
          icon: Icon(Icons.payments_outlined),
          selectedIcon: Icon(Icons.payments),
          label: 'Earnings',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

/// Side / bottom navigation for revenue & reporting layouts.
class AppNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 600;

    if (isWide) {
      return NavigationRail(
        selectedIndex: currentIndex.clamp(0, 4),
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        backgroundColor: AppTheme.surface,
        selectedIconTheme: IconThemeData(color: AppTheme.primaryColor),
        selectedLabelTextStyle: TextStyle(color: AppTheme.primaryColor),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: Text('Orders'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: Text('Menu'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: Text('Earn'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('Profile'),
          ),
        ],
      );
    }

    return NavigationBar(
      selectedIndex: currentIndex.clamp(0, 4),
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_menu_outlined),
          selectedIcon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        NavigationDestination(
          icon: Icon(Icons.payments_outlined),
          selectedIcon: Icon(Icons.payments),
          label: 'Earn',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
