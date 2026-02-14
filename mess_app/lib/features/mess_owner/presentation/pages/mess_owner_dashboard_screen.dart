import 'package:flutter/material.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/auth/user_session.dart';
import '../../../../core/app_export.dart';

class MessOwnerDashboardScreen extends StatelessWidget {
  const MessOwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(context, theme),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(theme),
            SizedBox(height: 3.h),
            _buildSectionTitle(theme, 'Active Orders'),
            SizedBox(height: 2.h),
            _buildOrdersList(theme),
            SizedBox(height: 3.h),
            _buildSectionTitle(theme, 'Today\'s Menu'),
            SizedBox(height: 2.h),
            _buildMenuCard(theme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard_fab',
        onPressed: () {},
        label: const Text('Update Menu'),
        icon: const CustomIconWidget(iconName: AppIcons.menu),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      title: Text(
        'Owner Dashboard',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Badge(
            label: Text('3'),
            child: CustomIconWidget(iconName: AppIcons.notifications, size: 24),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const CustomIconWidget(iconName: AppIcons.logout, color: Colors.red, size: 24),
          onPressed: () {
            UserSession().logout();
            Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
          },
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Row(
      children: [
        _buildStatCard(
          theme,
          'Total Orders',
          '124',
          AppIcons.cart,
          AppColors.primary,
        ),
        SizedBox(width: 4.w),
        _buildStatCard(
          theme,
          'Revenue',
          '₹12k',
          AppIcons.payments,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    String iconName,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomIconWidget(iconName: iconName, color: color, size: 20),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textHeader,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOrdersList(ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        return _buildOrderItem(theme, index);
      },
    );
  }

  Widget _buildOrderItem(ThemeData theme, int index) {
    final status = ['Pending', 'Preparing', 'Ready'];
    final colors = [AppColors.warning, AppColors.info, AppColors.success];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Lunch Mini Meal',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textBody),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: colors[index].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status[index],
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors[index],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   Text(
                    'Lunch Menu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LUNCH',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const CustomIconWidget(
                iconName: AppIcons.edit,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Dal Makhani, Jeera Rice, 3 Butter Roti, Paneer Masala, Salad, Gulab Jamun',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMenuStat('Predicted', '85'),
              _buildMenuStat('Confirmed', '62'),
              _buildMenuStat('Available', '23'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
