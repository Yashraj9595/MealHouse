import 'package:flutter/material.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/user/main_navigation_wrapper.dart';
import 'package:meal_house/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:meal_house/core/presentation/widgets/role_guard.dart';

import 'package:meal_house/features/admin/presentation/screens/admin_home.dart';
import 'package:meal_house/features/auth/presentation/screens/forgot_password/forgot_password_screen.dart';
import 'package:meal_house/features/auth/presentation/screens/login/login_screen.dart';
import 'package:meal_house/features/auth/presentation/screens/otp/otp_screen.dart';
import 'package:meal_house/features/auth/presentation/screens/registration/registration_screen.dart';
import 'package:meal_house/features/auth/presentation/screens/reset_password/reset_password_screen.dart';
import 'package:meal_house/features/auth/presentation/screens/welcome/welcome_screen.dart';
import 'package:meal_house/features/location/location_permission_screen/location_permission_screen.dart';
import 'package:meal_house/features/location/location_selection_screen/location_selection_screen.dart';
import 'package:meal_house/features/location/pickup_point_selection_screen/pickup_point_selection_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/earnings/earnings_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/menu/add_menu_item_screen/add_menu_item_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/menu/todays_menu_screen/todays_menu_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/menu_history/menu_history_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_orders/office_gate_pickup_screen/office_gate_pickup_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_orders/order_details_screen/order_details_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_orders/orders_screen/orders_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_orders/pickup_point_orders/pickup_point_orders_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_orders/todays_orders_screen/todays_orders_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_orders/update_order_status_screen/update_order_status_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/mess_owner_navigation_wrapper.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_profile/mess_details_screen/mess_details_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_profile/mess_location_screen/mess_location_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_profile/mess_profile_ready_screen/mess_profile_ready_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_profile/operating_hours_screen/operating_hours_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_profile/setup_mess_screen/setup_mess_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/mess_profile/upload_mess_photos_screen/upload_mess_photos_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/past_order_history/past_order_history_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/profile/profile_screen.dart'
    as owner_profile;
import 'package:meal_house/features/mess_owner/presentation/screens/profile/edit_mess_profile_screen.dart';
import 'package:meal_house/features/mess_owner/presentation/screens/profile/edit_owner_profile_screen.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart' as model;
import 'package:meal_house/features/mess_owner/domain/models/menu_model.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:meal_house/features/auth/domain/entities/user.dart' as auth_user;
import 'package:meal_house/features/mess_owner/presentation/screens/revenue_reports/revenue_reports_screen.dart';
import 'package:meal_house/features/notifications/notification_settings_screen/notification_settings_screen.dart';
import 'package:meal_house/features/notifications/notifications_screen/notifications_screen.dart';
import 'package:meal_house/features/order/presentation/screens/cancel_order/cancel_order_screen.dart';
import 'package:meal_house/features/order/presentation/screens/my_orders/my_orders_screen.dart';
import 'package:meal_house/features/order/presentation/screens/order_history/order_history_screen.dart';
import 'package:meal_house/features/order/presentation/screens/order_meal/order_meal_screen.dart';
import 'package:meal_house/features/order/presentation/screens/order_status/order_status_screen.dart';
import 'package:meal_house/features/order/presentation/screens/order_summary/order_summary_screen.dart';
import 'package:meal_house/features/order/presentation/screens/skip_meal/skip_meal_screen.dart';
import 'package:meal_house/features/order/presentation/screens/track_order/track_order_screen.dart';
import 'package:meal_house/features/order/presentation/screens/upcoming_orders/upcoming_orders_screen.dart';
import 'package:meal_house/features/profile/presentation/screens/edit_profile_screen/edit_profile_screen.dart';
import 'package:meal_house/features/profile/presentation/screens/pickup_preferences_screen/pickup_preferences_screen.dart';
import 'package:meal_house/features/profile/presentation/screens/profile_screen/profile_screen.dart' as customer;
import 'package:meal_house/features/profile/presentation/screens/saved_locations_screen/saved_locations_screen.dart';
import 'package:meal_house/features/profile/presentation/screens/settings_screen/settings_screen.dart';
import 'package:meal_house/features/review_screen/rate_review_screen/rate_review_screen.dart';
import 'package:meal_house/features/review_screen/review_submitted_screen/review_submitted_screen.dart';
import 'package:meal_house/features/settings/presentation/screens/faq_detail_screen/faq_detail_screen.dart';
import 'package:meal_house/features/settings/presentation/screens/help_support_screen/help_support_screen.dart';
import 'package:meal_house/features/settings/presentation/screens/report_problem_screen/report_problem_screen.dart';
import 'package:meal_house/features/user/home_screen/mess_near_you_screen/mess_near_you_screen.dart';
import 'package:meal_house/features/user/home_screen/recommended_for_you_screen/recommended_for_you_screen.dart';
import 'package:meal_house/features/user/mess_details/dish_detail_screen/dish_detail_screen.dart';
import 'package:meal_house/features/user/mess_details/menu_status_screen/menu_status_screen.dart';
import 'package:meal_house/features/user/mess_details/restaurant_detail_screen/restaurant_detail_screen.dart';
import 'package:meal_house/features/user/mess_details/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:meal_house/features/wallet/presentation/screens/my_wallet_screen/my_wallet_screen.dart';
import 'package:meal_house/features/wallet/presentation/screens/recharge_wallet_screen/recharge_wallet_screen.dart';
import 'package:meal_house/features/wallet/presentation/screens/transaction_history_screen/transaction_history_screen.dart';

/// Central route names and [MaterialApp.routes] table.
class AppRoutes {
  AppRoutes._();

  static const String initial = '/auth-wrapper';
  static const String authWrapper = '/auth-wrapper';
  static const String welcome = '/welcome';

  static const String locationPermissionScreen = '/location-permission-screen';
  static const String locationSelectionScreen = '/location-selection-screen';
  static const String pickupPointSelectionScreen = '/pickup-point-selection-screen';

  static const String homeScreen = '/home-screen';
  static const String messNearYou = '/mess-near-you';
  static const String recommendedForYou = '/recommended-for-you';

  static const String restaurantDetailScreen = '/restaurant-detail-screen';

  static const String dishDetailScreen = '/dish-detail-screen';
  static const String weeklyMenuScreen = '/weekly-menu-screen';
  static const String orderMealScreen = '/order-meal-screen';
  static const String menuStatusScreen = '/menu-status-screen';

  static const String orderSummary = '/order-summary';
  static const String orderStatus = '/order-status';
  static const String rateReview = '/rate-review';

  static const String myOrdersScreen = '/my-orders-screen';
  static const String cancelOrderScreen = '/cancel-order-screen';
  static const String upcomingOrdersScreen = '/upcoming-orders-screen';
  static const String orderHistoryScreen = '/order-history-screen';
  static const String reviewSubmittedScreen = '/review-submitted-screen';
  static const String skipMealScreen = '/skip-meal-screen';
  static const String trackOrderScreen = '/track-order-screen';

  static const String notificationsScreen = '/notifications-screen';
  static const String notificationSettingsScreen = '/notification-settings-screen';
  static const String profileScreen = '/profile-screen';
  static const String pickupPreferencesScreen = '/pickup-preferences-screen';
  static const String savedLocationsScreen = '/saved-locations-screen';
  static const String settingsScreen = '/settings-screen';
  static const String editProfileScreen = '/edit-profile-screen';

  static const String myWalletScreen = '/my-wallet-screen';
  static const String rechargeWalletScreen = '/recharge-wallet-screen';
  static const String transactionHistoryScreen = '/transaction-history-screen';

  static const String helpSupportScreen = '/help-support-screen';
  static const String faqDetailScreen = '/faq-detail-screen';
  static const String reportProblemScreen = '/report-problem-screen';

  static const String messDetailsScreen = '/mess-details-screen';
  static const String uploadMessPhotosScreen = '/upload-mess-photos-screen';
  static const String messLocationScreen = '/mess-location-screen';
  static const String operatingHoursScreen = '/operating-hours-screen';
  static const String messProfileReadyScreen = '/mess-profile-ready-screen';
  static const String dashboardScreen = '/dashboard-screen';
  static const String pickupPointOrdersScreen = '/pickup-point-orders-screen';
  static const String setupMessScreen = '/setup-mess-screen';

  static const String ordersScreen = '/orders-screen';
  static const String todaysOrdersScreen = '/todays-orders-screen';
  static const String todaysMenuScreen = '/todays-menu-screen';
  static const String addMenuItemScreen = '/add-menu-item-screen';
  static const String orderDetailsScreen = '/order-details-screen';
  static const String officeGatePickupScreen = '/office-gate-pickup-screen';
  static const String updateOrderStatusScreen = '/update-order-status-screen';

  static const String revenueReportsScreen = '/revenue-reports-screen';
  static const String earningsScreen = '/earnings-screen';
  static const String pastOrderHistoryScreen = '/past-order-history-screen';
  static const String menuHistoryScreen = '/menu-history-screen';
  static const String messOwnerProfileScreen = '/mess-owner-profile-screen';
  static const String editMessProfileScreen = '/edit-mess-profile-screen';
  static const String editOwnerProfileScreen = '/edit-owner-profile-screen';

  static const String loginScreen = '/login-screen';
  static const String registrationScreen = '/registration-screen';
  static const String forgotPasswordScreen = '/forgot-password-screen';
  static const String otpScreen = '/otp-screen';
  static const String resetPasswordScreen = '/reset-password-screen';
  static const String adminHomeScreen = '/admin-home-screen';

  // Dynamic Path Patterns
  static const String restaurantDetailPathPrefix = '/restaurant/';
  static const String dishDetailPathPrefix = '/dish/';
  static const String orderMealPathPrefix = '/order-meal/';
  static const String orderSummaryPathPrefix = '/order-summary/';
  static const String orderStatusPathPrefix = '/order-status/';

  static String restaurantDetailPath(String id) => '$restaurantDetailPathPrefix$id';
  static String dishDetailPath(String messId, String itemId) => 
      '$dishDetailPathPrefix${Uri.encodeComponent(messId)}/${Uri.encodeComponent(itemId)}';
  static String orderMealPath(String messId, String itemId) => 
      '$orderMealPathPrefix${Uri.encodeComponent(messId)}/${Uri.encodeComponent(itemId)}';
  static String orderSummaryPath(String messId) => 
      '$orderSummaryPathPrefix$messId';
  static String orderStatusPath(String orderId) => '$orderStatusPathPrefix$orderId';

  /// All named routes for [MaterialApp.routes].
  static Map<String, WidgetBuilder> get routes => {
        authWrapper: (_) => const AuthWrapper(),
        welcome: (_) => const WelcomeScreen(),
        locationPermissionScreen: (_) => const LocationPermissionScreen(),
        locationSelectionScreen: (_) => const LocationSelectionScreen(),
        pickupPointSelectionScreen: (_) => const PickupPointSelectionScreen(),
        homeScreen: (_) => const RoleGuard(
          allowedRoles: ['admin', 'manager', 'user'],
          child: MainNavigationWrapper(),
        ),
        messNearYou: (_) => const MessNearYouScreen(),
        recommendedForYou: (_) => const RecommendedForYouScreen(),
        restaurantDetailScreen: (_) => const RestaurantDetailScreen(),

        dishDetailScreen: (_) => const DishDetailScreen(),
        weeklyMenuScreen: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is model.MessModel) {
            return WeeklyMenuScreen(mess: args);
          }
          return const Scaffold(body: Center(child: Text('Invalid Mess Data for Weekly Menu')));
        },
        menuStatusScreen: (_) => const MenuStatusScreen(),
        orderSummary: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is model.MessModel) {
            return OrderSummaryScreen(mess: args);
          }
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text('Invalid Mess Data for Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                   Text('Args: ${args?.runtimeType}'),
                ],
              ),
            ),
          );
        },
        orderStatus: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is model.MessModel) {
            return OrderStatusScreen(mess: args);
          }
          // Permit OrderStatusScreen to handle its own fetching via URL segments
          return const OrderStatusScreen();
        },
        orderMealScreen: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map) {
            final dynamic mess = args['mess'];
            final dynamic item = args['item'];
            if (mess != null && item != null) {
              return OrderMealScreen(mess: mess as model.MessModel, menuItem: item as MenuItemModel);
            }
          }
          // If we reach here, it might be a direct named push without args logic.
          // This allows OrderMealScreen to handle its own loading.
          return const OrderMealScreen();
        },
        trackOrderScreen: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is model.MessModel) {
            return TrackOrderScreen(mess: args);
          }
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text('Invalid Mess Data for Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
                   Text('Args: ${args?.runtimeType}'),
                ],
              ),
            ),
          );
        },
        rateReview: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final mess = args is model.MessModel ? args : null;
          if (mess == null) return const Scaffold(body: Center(child: Text('Invalid Mess Data')));
          return RateReviewScreen(mess: mess);
        },
        myOrdersScreen: (_) => const MyOrdersScreen(),
        cancelOrderScreen: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final order = args is OrderModel ? args : null;
          if (order == null) return const Scaffold(body: Center(child: Text('Invalid Order Data')));
          return CancelOrderScreen(order: order);
        },
        upcomingOrdersScreen: (_) => const UpcomingOrdersScreen(),
        orderHistoryScreen: (_) => const OrderHistoryScreen(),
        reviewSubmittedScreen: (_) => const ReviewSubmittedScreen(),
        skipMealScreen: (_) => const SkipMealScreen(),
        notificationsScreen: (_) => const NotificationsScreen(),
        notificationSettingsScreen: (_) => const NotificationSettingsScreen(),
        profileScreen: (_) => const customer.ProfileScreen(),
        pickupPreferencesScreen: (_) => const PickupPreferencesScreen(),
        savedLocationsScreen: (_) => const SavedLocationsScreen(),
        settingsScreen: (_) => const SettingsScreen(),
        editProfileScreen: (_) => const EditProfileScreen(),
        myWalletScreen: (_) => const MyWalletScreen(),
        rechargeWalletScreen: (_) => const RechargeWalletScreen(),
        transactionHistoryScreen: (_) => const TransactionHistoryScreen(),
        helpSupportScreen: (_) => const HelpSupportScreen(),
        faqDetailScreen: (_) => const FaqDetailScreen(),
        reportProblemScreen: (_) => const ReportProblemScreen(),
        messDetailsScreen: (_) => const MessDetailsScreen(),
        uploadMessPhotosScreen: (context) {
          final mess = ModalRoute.of(context)?.settings.arguments as model.MessModel?;
          return UploadMessPhotosScreen(initialMess: mess);
        },
        messLocationScreen: (context) {
          final mess = ModalRoute.of(context)?.settings.arguments as model.MessModel?;
          return MessLocationScreen(initialMess: mess);
        },
        operatingHoursScreen: (context) {
          final mess = ModalRoute.of(context)?.settings.arguments as model.MessModel?;
          return OperatingHoursScreen(initialMess: mess);
        },
        messProfileReadyScreen: (_) => const MessProfileReadyScreen(),
        dashboardScreen: (_) => const RoleGuard(
          allowedRoles: ['admin', 'manager'],
          child: MessOwnerNavigationWrapper(),
        ),
        pickupPointOrdersScreen: (_) => const PickupPointOrdersScreen(),
        setupMessScreen: (_) => const SetupMessScreen(),
        ordersScreen: (_) => const OrdersScreen(),
        todaysOrdersScreen: (_) => const TodaysOrdersScreen(),
        todaysMenuScreen: (_) => const TodaysMenuScreen(),
        addMenuItemScreen: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return AddMenuItemScreen(
            initialItem: args?['item'],
            itemIndex: args?['index'],
          );
        },
        orderDetailsScreen: (context) {
          final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
          return OrderDetailsScreen(order: order);
        },
        officeGatePickupScreen: (_) => const OfficeGatePickupScreen(),
        updateOrderStatusScreen: (_) => const UpdateOrderStatusScreen(),
        revenueReportsScreen: (_) => const RevenueReportsScreen(),
        earningsScreen: (_) => const EarningsScreen(),
        pastOrderHistoryScreen: (_) => const PastOrderHistoryScreen(),
        menuHistoryScreen: (_) => const MenuHistoryScreen(),
        messOwnerProfileScreen: (_) => const owner_profile.MessOwnerProfileScreen(),
        editMessProfileScreen: (context) {
          final mess = ModalRoute.of(context)!.settings.arguments as model.MessModel;
          return EditMessProfileScreen(mess: mess);
        },
        editOwnerProfileScreen: (context) {
          final user = ModalRoute.of(context)!.settings.arguments as auth_user.User;
          return EditOwnerProfileScreen(user: user);
        },
        loginScreen: (_) => const LoginScreen(),
        registrationScreen: (_) => const RegistrationScreen(),
        forgotPasswordScreen: (_) => const ForgotPasswordScreen(),
        otpScreen: (_) => const OTPScreen(email: ''),
        resetPasswordScreen: (_) =>
            const ResetPasswordScreen(email: '', otp: ''),
        adminHomeScreen: (_) => const RoleGuard(
          allowedRoles: ['admin'],
          child: AdminHomeScreen(),
        ),
      };

  /// Main router handler for [MaterialApp.onGenerateRoute].
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    if (name == null) return null;

    // Handle both cases: /restaurant/ and restaurant/
    String restaurantPrefix = name.startsWith('/') ? restaurantDetailPathPrefix : restaurantDetailPathPrefix.substring(1);
    if (name.startsWith(restaurantPrefix)) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const RestaurantDetailScreen(),
      );
    }

    // Handle both cases: /dish/ and dish/
    String dishPrefix = name.startsWith('/') ? dishDetailPathPrefix : dishDetailPathPrefix.substring(1);
    if (name.startsWith(dishPrefix)) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const DishDetailScreen(),
      );
    }

    // Handle both cases: /order-meal/ and order-meal/
    String orderPrefix = name.startsWith('/') ? orderMealPathPrefix : orderMealPathPrefix.substring(1);
    if (name.startsWith(orderPrefix)) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OrderMealScreen(),
      );
    }

    // 3. Handle Order Status Segmented Path
    String orderStatusPrefix = name.startsWith('/') ? orderStatusPathPrefix : orderStatusPathPrefix.substring(1);
    if (name.startsWith(orderStatusPrefix)) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OrderStatusScreen(),
      );
    }

    // 4. Handle Order Summary Segmented Path
    String orderSummaryPrefix = name.startsWith('/') ? orderSummaryPathPrefix : orderSummaryPathPrefix.substring(1);
    if (name.startsWith(orderSummaryPrefix)) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OrderSummaryScreen(),
      );
    }

    // Default to lookup in the static routes map
    final builder = routes[name];
    if (builder != null) {
      return MaterialPageRoute(
        settings: settings,
        builder: builder,
      );
    }

    return null;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded, size: 56, color: AppTheme.primary),
                const SizedBox(height: 12),
                const Text(
                  'This route is not available in the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  settings.name ?? '(unknown route)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    homeScreen,
                    (route) => false,
                  ),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
