import 'package:MealHouse/core/app_export.dart';
import 'package:MealHouse/shared/widgets/custom_bottom_bar.dart';
import './user_home_page.dart';
import '../../../orders/presentation/pages/orders_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

class UserHomeContainer extends StatefulWidget {
  const UserHomeContainer({super.key});

  @override
  UserHomeContainerState createState() => UserHomeContainerState();
}

class UserHomeContainerState extends State<UserHomeContainer> {
  int currentIndex = 0;
  final List<bool> _initializedPages = [true, false, false];

  final List<Widget> pages = [
    const UserHomePage(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: List.generate(pages.length, (index) {
          if (_initializedPages[index]) {
            return pages[index];
          } else {
            return const SizedBox.shrink();
          }
        }),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        items: [
          BottomBarItem(iconName: AppIcons.home, label: 'Home'),
          BottomBarItem(iconName: AppIcons.orders, label: 'Orders'),
          BottomBarItem(iconName: AppIcons.profile, label: 'Profile'),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
            _initializedPages[index] = true;
          });
        },
      ),
    );
  }
}
