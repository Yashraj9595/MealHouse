import 'package:flutter/material.dart';
import 'package:meal_house/features/user/home_screen/home_screen/home_screen.dart';
import 'package:meal_house/features/order/presentation/screens/my_orders/my_orders_screen.dart';
import 'package:meal_house/features/order/presentation/screens/upcoming_orders/upcoming_orders_screen.dart';
import 'package:meal_house/features/wallet/presentation/screens/my_wallet_screen/my_wallet_screen.dart';
import 'package:meal_house/features/profile/presentation/screens/profile_screen/profile_screen.dart';
import 'package:meal_house/features/user/home_screen/home_screen/widgets/home_bottom_nav_widget.dart';
import 'package:meal_house/shared/notifications/tab_change_notification.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyOrdersScreen(),
    const UpcomingOrdersScreen(),
    const MyWalletScreen(),
    const ProfileScreen(),
  ];

  void _onIndexChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: const Color(0xFFFFF7F2),
      body: NotificationListener<TabChangeNotification>(
        onNotification: (notification) {
          setState(() {
            _selectedIndex = notification.index;
          });
          return true;
        },
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: HomeBottomNavWidget(
        selectedIndex: _selectedIndex,
        onIndexChanged: _onIndexChanged,
      ),
    );
  }
}
