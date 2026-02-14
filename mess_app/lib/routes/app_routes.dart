import 'package:flutter/material.dart';
import '../features/user/home/presentation/pages/home_container_screen.dart';
import '../features/user/presentation/pages/mess_detail_screen.dart';
import '../features/user/presentation/pages/meal_group_detail_screen.dart';
import '../features/user/notifications/presentation/pages/notifications_screen.dart';
import '../features/user/orders/presentation/pages/orders_screen.dart';
import '../features/user/payments/presentation/pages/payments_screen.dart';
import '../features/user/profile/presentation/pages/profile_screen.dart';
import '../features/user/profile/presentation/pages/address_screen.dart';
import '../features/user/profile/presentation/pages/settings_screen.dart';
import '../features/user/profile/presentation/pages/edit_profile_screen.dart';
import '../features/user/subscription/presentation/pages/subscription_screen.dart';
import '../features/mess_owner/presentation/pages/mess_owner_dashboard_screen.dart';
import '../features/mess_owner/presentation/pages/owner_container_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/admin_container_screen.dart';
import '../core/widgets/protected_route.dart';
import '../core/auth/user_session.dart';

class AppRoutes {
  static const String loginScreen = '/login';
  static const String registerScreen = '/register';
  static const String forgotPasswordScreen = '/forgot-password';
  static const String otpScreen = '/otp';
  static const String adminDashboard = '/admin-dashboard';
  static const String customerHomeScreen = '/customer-home-screen';
  static const String messDetailScreen = '/mess-detail-screen';
  static const String mealGroupDetailScreen = '/meal-group-detail-screen';
  static const String notificationsScreen = '/notifications-screen';
  static const String ordersScreen = '/orders-screen';
  static const String paymentsScreen = '/payments-screen';
  static const String profileScreen = '/profile-screen';
  static const String subscriptionScreen = '/subscription-screen';
  static const String addressScreen = '/address-screen';
  static const String settingsScreen = '/settings-screen';
  static const String editProfileScreen = '/edit-profile-screen';
  static const String messOwnerDashboard = '/mess-owner-dashboard';

  static Map<String, WidgetBuilder> get routes => {
    loginScreen: (context) => const LoginScreen(),
    registerScreen: (context) => const RegisterScreen(),
    forgotPasswordScreen: (context) => const ForgotPasswordScreen(),
    otpScreen: (context) => const OTPScreen(),
    customerHomeScreen: (context) => const ProtectedRoute(
      requiredRole: UserRole.user,
      child: HomeContainerScreen(),
    ),
    messDetailScreen: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return MessDetailScreen(mess: args);
    },
    notificationsScreen: (context) => const NotificationsScreen(),
    ordersScreen: (context) => const OrdersScreen(),
    paymentsScreen: (context) => const PaymentsScreen(),
    profileScreen: (context) => const ProfileScreen(),
    subscriptionScreen: (context) => const SubscriptionScreen(),
    addressScreen: (context) => const AddressScreen(),
    settingsScreen: (context) => const SettingsScreen(),
    editProfileScreen: (context) => const EditProfileScreen(),
    mealGroupDetailScreen: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return MealGroupDetailScreen(mealGroup: args);
    },
    messOwnerDashboard: (context) => const ProtectedRoute(
      requiredRole: UserRole.messOwner,
      child: OwnerContainerScreen(),
    ),
    adminDashboard: (context) => const ProtectedRoute(
      requiredRole: UserRole.admin,
      child: AdminContainerScreen(),
    ),
  };
}
