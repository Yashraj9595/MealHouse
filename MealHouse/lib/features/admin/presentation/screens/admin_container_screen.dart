import '../../../../shared/widgets/custom_bottom_bar.dart';
import 'package:MealHouse/core/app_export.dart';
import './admin_dashboard_screen.dart';

class AdminContainerScreen extends StatefulWidget {
  const AdminContainerScreen({super.key});

  @override
  State<AdminContainerScreen> createState() => _AdminContainerScreenState();
}

class _AdminContainerScreenState extends State<AdminContainerScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const AdminDashboardScreen(),
    const Scaffold(body: Center(child: Text('Users Management'))),
    const Scaffold(body: Center(child: Text('Messes Management'))),
    const Scaffold(body: Center(child: Text('Admin Profile'))),
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
          BottomBarItem(iconName: AppIcons.home, label: 'Analytics'),
          BottomBarItem(iconName: AppIcons.profile, label: 'Users'),
          BottomBarItem(iconName: AppIcons.menu, label: 'Messes'),
          BottomBarItem(iconName: AppIcons.settings, label: 'Settings'),
        ],
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}
