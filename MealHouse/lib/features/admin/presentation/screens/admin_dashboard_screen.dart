import 'package:MealHouse/core/app_export.dart';
import 'package:MealHouse/routes/app_routes.dart';
import 'package:MealHouse/core/auth/user_session.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: AppColors.textHeader, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const CustomIconWidget(iconName: AppIcons.logout, color: Colors.red),
            onPressed: () {
              UserSession().logout();
              Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
            },
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Center(
        child: Text(
          'Admin Dashboard Content Coming Soon',
          style: TextStyle(color: AppColors.textBody, fontSize: 18),
        ),
      ),
    );
  }
}
