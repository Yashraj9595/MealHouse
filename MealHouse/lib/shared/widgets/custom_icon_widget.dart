import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final Color? color;
  final double? size;

  const CustomIconWidget({
    super.key,
    required this.iconName,
    this.color,
    this.size,
  });

  IconData _getIconData(String name) {
    switch (name) {
      case 'location_on': return Icons.location_on_rounded;
      case 'keyboard_arrow_down': return Icons.keyboard_arrow_down_rounded;
      case 'search': return Icons.search_rounded;
      case 'tune': return Icons.tune_rounded;
      case 'favorite_border': return Icons.favorite_border_rounded;
      case 'share': return Icons.share_rounded;
      case 'restaurant_menu': return Icons.restaurant_menu_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'star': return Icons.star_rounded;
      case 'close': return Icons.close_rounded;
      case 'circle': return Icons.circle;
      case 'access_time': return Icons.access_time_rounded;
      case 'home': return Icons.home_rounded;
      case 'person': return Icons.person_rounded;
      case 'history': return Icons.history_rounded;
      case 'dashboard': return Icons.dashboard_rounded;
      case 'arrow_back': return Icons.arrow_back_ios_new_rounded;
      case 'favorite': return Icons.favorite_rounded;
      case 'star_border': return Icons.star_border_rounded;
      case 'phone': return Icons.phone_rounded;
      case 'directions': return Icons.directions_rounded;
      case 'call': return Icons.call_rounded;
      case 'verified': return Icons.verified_rounded;
      case 'check_circle': return Icons.check_circle_rounded;
      case 'expand_less': return Icons.expand_less_rounded;
      case 'expand_more': return Icons.expand_more_rounded;
      case 'notifications': return Icons.notifications_none_rounded;
      case 'shopping_bag': return Icons.shopping_bag_outlined;
      case 'payments': return Icons.payments_outlined;
      case 'subscriptions': return Icons.card_membership_rounded;
      case 'settings': return Icons.settings_outlined;
      case 'help': return Icons.help_outline_rounded;
      case 'logout': return Icons.logout_rounded;
      case 'delete': return Icons.delete_outline_rounded;
      case 'add': return Icons.add_rounded;
      case 'more_vert': return Icons.more_vert_rounded;
      case 'account_balance': return Icons.account_balance_rounded;
      case 'chevron_right': return Icons.chevron_right_rounded;
      case 'credit_card': return Icons.credit_card_rounded;
      case 'calendar': return Icons.calendar_today_rounded;
      case 'local_offer': return Icons.local_offer_rounded;
      case 'warning': return Icons.warning_rounded;
      case 'edit': return Icons.edit_rounded;
      case 'admin': return Icons.admin_panel_settings_rounded;
      case 'person_outline': return Icons.person_outline_rounded;
      case 'restaurant_outline': return Icons.restaurant_outlined;
      case 'email': return Icons.email_rounded;
      case 'lock': return Icons.lock_outline_rounded;
      case 'visibility': return Icons.visibility_rounded;
      case 'visibility_off': return Icons.visibility_off_rounded;
      case 'work': return Icons.work_rounded;
      case 'location_city': return Icons.location_city_rounded;
      case 'security': return Icons.security_rounded;
      case 'language': return Icons.language_rounded;
      case 'info_outline': return Icons.info_outline_rounded;
      case 'save': return Icons.save_rounded;
      case 'photo_camera': return Icons.camera_alt_rounded;
      case 'videocam': return Icons.videocam_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconData(iconName),
      color: color,
      size: size,
    );
  }
}
