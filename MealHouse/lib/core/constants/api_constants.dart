class ApiConstants {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String getProfile = '/auth/me';
  static const String updateProfile = '/auth/updatedetails'; // Fixed to match actual usage

  // Mess endpoints
  static const String messes = '/messes';
  static const String messDetail = '/messes';
  static const String myMess = '/messes/my';

  // Meal group endpoints
  static const String mealGroups = '/mealgroups';
  static const String mealGroupDetail = '/mealgroups';

  // Order endpoints
  static const String orders = '/orders';
  static const String orderDetail = '/orders';
  static const String createOrder = '/orders';

  // Helper methods
  static String messDetailPath(String id) => '$messDetail/$id';
  static String mealGroupDetailPath(String id) => '$mealGroupDetail/$id';
  static String orderDetailPath(String id) => '$orderDetail/$id';
  static String messMealGroupsPath(String messId) => '$messes/$messId/mealgroups';
}