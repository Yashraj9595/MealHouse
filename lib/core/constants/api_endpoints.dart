/// REST paths relative to [AppConfig.apiBaseUrl], which must end with `/api/v1/`.
class ApiEndpoints {
  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh-token';
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resetPassword = 'auth/reset-password';

  // User
  static const String userProfile = 'auth/profile';
  static String updateProfile = 'auth/profile';
  static const String uploadProfilePhoto = 'auth/upload-profile-photo';
  static const String changePassword = 'auth/change-password';
  static const String deleteAccount = 'users/delete';

  // Mess
  static const String messes = 'messes';
  static const String myMesses = 'messes/my/messes';
  static const String menus = 'menus';
  
  // Orders
  static const String orders = 'orders';
  static const String myOrders = 'orders/my/orders';
  static const String messOrders = 'orders/mess';
  static const String updateOrderStatus = 'orders/status';
  static const String verifyRazorpay = 'orders/razorpay/verify';
  static const String messDashboardStats = 'orders/mess';

  // Wallet
  static const String walletBalance = 'wallet/balance';
  static const String walletTransactions = 'wallet/transactions';
  static const String addMoney = 'wallet/add';
  static const String withdrawMoney = 'wallet/withdraw';

  // Pickup points
  static const String pickupPoints = 'pickup-points';
  static const String pickupPointsNearby = 'pickup-points/nearby';

  // Notifications
  static const String notifications = 'notifications';
  static const String markNotificationRead = 'notifications/read';

  // Admin
  static const String adminUsers = 'admin/users';
  static const String adminMessOwners = 'admin/mess-owners';
  static const String adminApproveMess = 'admin/approve-mess';
  static const String adminTransactions = 'admin/transactions';

  /// Health check at server root (use with full URL if base is `/api/v1/`).
  static const String health = '/health';

  ApiEndpoints._();
}
