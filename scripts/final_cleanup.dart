import 'dart:io';

void main() {
  // 1. Fix ApiClient imports
  final apiFile = File('lib/core/network/api_client.dart');
  if (apiFile.existsSync()) {
    var content = apiFile.readAsStringSync();
    content = content.replaceAll(
      'import \'../exceptions/app_exceptions.dart\';',
      'import \'package:meal_house/core/error/app_exceptions.dart\';'
    );
    apiFile.writeAsStringSync(content);
    print('Fixed ApiClient exceptions import');
  }

  // 2. Fix AppRoutes imports for pickups and profile
  final routesFile = File('lib/core/router/app_routes.dart');
  if (routesFile.existsSync()) {
    var content = routesFile.readAsStringSync();
    content = content.replaceAll(
      'package:meal_house/features/mess_owner/presentation/screens/mess_orders/pickup_point_orders_screen/pickup_point_orders_screen.dart',
      'package:meal_house/features/mess_owner/presentation/screens/mess_orders/pickup_point_orders/pickup_point_orders_screen.dart'
    );
    content = content.replaceAll(
      'package:meal_house/features/profile/profile_screen/profile_screen.dart',
      'package:meal_house/features/profile/presentation/screens/profile_screen/profile_screen.dart'
    );
    routesFile.writeAsStringSync(content);
    print('Fixed AppRoutes imports');
  }

  // 3. Fix shared widgets imports of AppTheme
  final sharedWidgets = [
    'lib/shared/widgets/mess_owner_app_navigation.dart',
    'lib/shared/widgets/status_badge_widget.dart',
  ];
  for (var path in sharedWidgets) {
    final file = File(path);
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();
    content = content.replaceAll(
      'import \'../theme/app_theme.dart\';',
      'import \'package:meal_house/core/theme/app_theme.dart\';'
    );
    file.writeAsStringSync(content);
    print('Fixed themed import in $path');
  }

  // 4. Inject mapping function into order widgets
  final mappingFunction = '''
  BadgeStatus _mapOrderStatusToBadgeStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return BadgeStatus.confirmed;
      case OrderStatus.preparing:
        return BadgeStatus.preparing;
      case OrderStatus.delivered:
        return BadgeStatus.delivered;
      case OrderStatus.cancelled:
        return BadgeStatus.cancelled;
      default:
        return BadgeStatus.confirmed;
    }
  }
''';

  final orderWidgets = [
    'lib/features/order/presentation/widgets/active_order_card_widget.dart',
    'lib/features/order/presentation/widgets/cancelled_order_card_widget.dart',
    'lib/features/order/presentation/widgets/upcoming_order_card_widget.dart',
  ];

  for (var path in orderWidgets) {
    final file = File(path);
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();
    if (!content.contains('_mapOrderStatusToBadgeStatus')) {
      final stateMatch = RegExp(r'class _(\w+)State extends State<(\w+)> (?:with [\w, ]+ )?\{').firstMatch(content);
      if (stateMatch != null) {
        final insertIndex = stateMatch.end;
        content = '${content.substring(0, insertIndex)}\n$mappingFunction${content.substring(insertIndex)}';
        file.writeAsStringSync(content);
        print('Injected mapping into $path');
      }
    }
  }
  
  // 5. Fix developer_page imports
  final devPage = File('lib/core/presentation/screens/developer_page.dart');
  if (devPage.existsSync()) {
    var content = devPage.readAsStringSync();
    content = content.replaceAll(
      'import \'../../../shared/theme/app_theme.dart\';',
      'import \'package:meal_house/core/theme/app_theme.dart\';'
    );
    content = content.replaceAll(
      'import \'package:meal_house/features/mess_owner/mess_profile/dashboard_screen/dashboard_screen.dart\';',
      'import \'package:meal_house/features/mess_owner/presentation/screens/dashboard/dashboard_screen.dart\';'
    );
    devPage.writeAsStringSync(content);
    print('Fixed developer_page imports');
  }
}
