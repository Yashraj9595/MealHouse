import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/custom_bottom_bar.dart';
import './customer_home_initial_page.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  CustomerHomeScreenState createState() => CustomerHomeScreenState();
}

class CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int currentIndex = 0;

  final List<String> routes = [
    '/customer-home-screen',
    '/mess-detail-screen',
    '/meal-group-detail-screen',
    '/mess-owner-dashboard',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: navigatorKey,
        initialRoute: '/customer-home-screen',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/customer-home-screen' || '/':
              return MaterialPageRoute(
                builder: (context) => const CustomerHomeInitialPage(),
                settings: settings,
              );
            default:
              if (AppRoutes.routes.containsKey(settings.name)) {
                return MaterialPageRoute(
                  builder: AppRoutes.routes[settings.name]!,
                  settings: settings,
                );
              }
              return null;
          }
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (currentIndex != index) {
            setState(() => currentIndex = index);
            // In a real app, we might use a different navigation strategy for the bottom bar
            // but for now keeping the user's logic
            if (AppRoutes.routes.containsKey(routes[index])) {
                navigatorKey.currentState?.pushReplacementNamed(routes[index]);
            }
          }
        },
      ),
    );
  }
}
