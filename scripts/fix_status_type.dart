import 'dart:io';

void main() {
  final file = File('lib/features/user/home_screen/home_screen/widgets/home_popular_today_widget.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll('StatusType', 'BadgeStatus');
    // Ensure we import BadgeStatus
    if (!content.contains('package:meal_house/shared/widgets/status_badge_widget.dart')) {
       content = "import 'package:meal_house/shared/widgets/status_badge_widget.dart';\n$content";
    }
    file.writeAsStringSync(content);
    print('Fixed StatusType in home_popular_today_widget.dart');
  }

  final file2 = File('lib/features/user/home_screen/home_screen/widgets/home_thali_cards_widget.dart');
  if (file2.existsSync()) {
    var content = file2.readAsStringSync();
    content = content.replaceAll('StatusType', 'BadgeStatus');
    if (!content.contains('package:meal_house/shared/widgets/status_badge_widget.dart')) {
       content = "import 'package:meal_house/shared/widgets/status_badge_widget.dart';\n$content";
    }
    file2.writeAsStringSync(content);
    print('Fixed StatusType in home_thali_cards_widget.dart');
  }
}
