import 'dart:io';

void main() {
  final filesToFix = [
    'lib/features/user/home_screen/home_screen/widgets/home_popular_today_widget.dart',
    'lib/features/user/home_screen/home_screen/widgets/home_thali_cards_widget.dart',
    'lib/features/user/mess_details/restaurant_detail_screen/widgets/action_buttons_widget.dart',
    'lib/features/user/mess_details/restaurant_detail_screen/widgets/cart_bar_widget.dart',
    'lib/features/user/mess_details/restaurant_detail_screen/widgets/filter_tags_widget.dart',
    'lib/features/user/mess_details/restaurant_detail_screen/widgets/hero_header_widget.dart',
    'lib/features/user/mess_details/restaurant_detail_screen/widgets/info_cards_widget.dart',
    'lib/features/user/mess_details/restaurant_detail_screen/widgets/meal_slot_buttons_widget.dart',
    'lib/features/user/mess_details/restaurant_detail_screen/widgets/todays_thalis_widget.dart',
  ];

  for (var filePath in filesToFix) {
    var file = File(filePath);
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();
    var changed = false;

    // Add GoogleFonts import if missing and used
    if (content.contains('GoogleFonts.') && !content.contains('package:google_fonts/google_fonts.dart')) {
      content = "import 'package:google_fonts/google_fonts.dart';\n$content";
      changed = true;
    }

    // Add CustomImageWidget import if missing and used
    if (content.contains('CustomImageWidget(') && !content.contains('package:meal_house/shared/widgets/custom_image_widget.dart')) {
      content = "import 'package:meal_house/shared/widgets/custom_image_widget.dart';\n$content";
      changed = true;
    }

    // Fix specific AppTheme missing getters if they are still failing
    // Based on analysis, they might be using lowercase names that were added as static getters
    
    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed feature-specific issues in $filePath');
    }
  }
}
