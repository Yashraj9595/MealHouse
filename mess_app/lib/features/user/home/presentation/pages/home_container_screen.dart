import '../../../../../core/app_export.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../shared/widgets/custom_bottom_bar.dart';
import './home_page.dart';
import '../../../orders/presentation/pages/orders_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
// import '../../../../../features/mess_owner/presentation/pages/mess_owner_dashboard_screen.dart';

class HomeContainerScreen extends StatefulWidget {
  const HomeContainerScreen({super.key});

  @override
  HomeContainerScreenState createState() => HomeContainerScreenState();
}

class HomeContainerScreenState extends State<HomeContainerScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        items: [
          BottomBarItem(iconName: AppIcons.home, label: 'Home'),
          BottomBarItem(iconName: AppIcons.orders, label: 'Orders'),
          BottomBarItem(iconName: AppIcons.profile, label: 'Profile'),
        ],
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}
