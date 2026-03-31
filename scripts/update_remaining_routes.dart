import 'dart:io';

void main() {
  final routesFile = File('lib/core/router/app_routes.dart');
  if (!routesFile.existsSync()) return;

  var content = routesFile.readAsStringSync();
  
  final mappings = {
    // Settings
    'import \'package:meal_house/features/settings/faq_detail_screen/faq_detail_screen.dart\';': 
    'import \'package:meal_house/features/settings/presentation/screens/faq_detail_screen/faq_detail_screen.dart\';',
    'import \'package:meal_house/features/settings/help_support_screen/help_support_screen.dart\';':
    'import \'package:meal_house/features/settings/presentation/screens/help_support_screen/help_support_screen.dart\';',
    'import \'package:meal_house/features/settings/report_problem_screen/report_problem_screen.dart\';':
    'import \'package:meal_house/features/settings/presentation/screens/report_problem_screen/report_problem_screen.dart\';',
    
    // Wallet
    'import \'package:meal_house/features/wallet/my_wallet_screen/my_wallet_screen.dart\';':
    'import \'package:meal_house/features/wallet/presentation/screens/my_wallet_screen/my_wallet_screen.dart\';',
    'import \'package:meal_house/features/wallet/recharge_wallet_screen/recharge_wallet_screen.dart\';':
    'import \'package:meal_house/features/wallet/presentation/screens/recharge_wallet_screen/recharge_wallet_screen.dart\';',
    'import \'package:meal_house/features/wallet/transaction_history_screen/transaction_history_screen.dart\';':
    'import \'package:meal_house/features/wallet/presentation/screens/transaction_history_screen/transaction_history_screen.dart\';',
    
    // Profile
    'import \'package:meal_house/features/profile_screen/profile_screen/profile_screen.dart\';':
    'import \'package:meal_house/features/profile/presentation/screens/profile_screen/profile_screen.dart\';',
    'import \'package:meal_house/features/profile_screen/edit_profile_screen/edit_profile_screen.dart\';':
    'import \'package:meal_house/features/profile/presentation/screens/edit_profile_screen/edit_profile_screen.dart\';',
    'import \'package:meal_house/features/profile_screen/pickup_preferences_screen/pickup_preferences_screen.dart\';':
    'import \'package:meal_house/features/profile/presentation/screens/pickup_preferences_screen/pickup_preferences_screen.dart\';',
    'import \'package:meal_house/features/profile_screen/saved_locations_screen/saved_locations_screen.dart\';':
    'import \'package:meal_house/features/profile/presentation/screens/saved_locations_screen/saved_locations_screen.dart\';',
    'import \'package:meal_house/features/profile_screen/settings_screen/settings_screen.dart\';':
    'import \'package:meal_house/features/profile/presentation/screens/settings_screen/settings_screen.dart\';',
  };

  mappings.forEach((oldPath, newPath) {
    content = content.replaceAll(oldPath, newPath);
  });
  
  // Also catch any generic profile_screen/ to profile/ conversions
  content = content.replaceAll('package:meal_house/features/profile_screen/', 'package:meal_house/features/profile/');

  routesFile.writeAsStringSync(content);
  print('Updated AppRoutes imports for Settings, Wallet, and Profile.');
}
