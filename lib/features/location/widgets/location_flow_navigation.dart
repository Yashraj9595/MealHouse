import 'package:flutter/material.dart';

/// Bottom bar for location onboarding (selection / pickup). Not the mess-owner rail.
class LocationFlowNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LocationFlowNavigation({
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
          icon: Icon(Icons.place_outlined),
          selectedIcon: Icon(Icons.place_rounded),
          label: 'Location',
        ),
        NavigationDestination(
          icon: Icon(Icons.navigation_outlined),
          selectedIcon: Icon(Icons.navigation_rounded),
          label: 'Route',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications_rounded),
          label: 'Alerts',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
