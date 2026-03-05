import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/custom_bottom_bar.dart';
import 'package:MealHouse/core/app_export.dart';
import './mess_owner_dashboard_screen.dart';
import '../../profile/presentation/screens/owner_profile_screen.dart';
import '../../order_management/presentation/screens/order_list_screen.dart';
import '../../meal_management/presentation/screens/meal_group_list_screen.dart';
import '../../profile/presentation/state/mess_profile_providers.dart';

class OwnerContainerScreen extends ConsumerStatefulWidget {
  const OwnerContainerScreen({super.key});

  @override
  ConsumerState<OwnerContainerScreen> createState() => _OwnerContainerScreenState();
}

class _OwnerContainerScreenState extends ConsumerState<OwnerContainerScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(messProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        data: (profile) {
          final List<Widget> pages = [
            const MessOwnerDashboardScreen(),
            const OrderListScreen(),
             MealGroupListScreen(messId: profile.id),
            const OwnerProfileScreen(),
          ];

          return IndexedStack(
            index: currentIndex,
            children: pages,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load profile: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(messProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        items: [
          BottomBarItem(iconName: AppIcons.home, label: 'Dashboard'),
          BottomBarItem(iconName: AppIcons.orders, label: 'Orders'),
          BottomBarItem(iconName: AppIcons.menu, label: 'Menu'),
          BottomBarItem(iconName: AppIcons.profile, label: 'Profile'),
        ],
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}
