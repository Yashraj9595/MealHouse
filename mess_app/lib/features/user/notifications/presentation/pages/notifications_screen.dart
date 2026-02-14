import 'package:flutter/material.dart';
import '../../../../../core/app_export.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        itemCount: 4,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        itemBuilder: (context, index) {
          return _buildNotificationItem(theme, index);
        },
      ),
    );
  }

  Widget _buildNotificationItem(ThemeData theme, int index) {
    final titles = [
      'Order Delivered!',
      'Today\'s Menu Updated',
      'Exclusive Offer!',
      'Subscription Expiring'
    ];
    final subs = [
      'Your meal from Annapurna Mess has been delivered.',
      'Check out the special menu at Punjabi Dhaba.',
      'Get 20% off on your next 5 meals.',
      'Your monthly subscription ends in 2 days.'
    ];
    final iconNames = [
      AppIcons.checkGroup,
      AppIcons.menu,
      AppIcons.offer,
      AppIcons.warning,
    ];
    final colors = [
      AppColors.success,
      AppColors.info,
      Colors.orange,
      AppColors.warning,
    ];

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors[index].withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: iconNames[index],
          color: colors[index],
          size: 24,
        ),
      ),
      title: Text(
        titles[index],
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textHeader,
        ),
      ),
      subtitle: Text(
        subs[index],
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textBody,
        ),
      ),
      trailing: Text(
        '2h ago',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.grey.shade500,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      onTap: () {},
    );
  }
}
