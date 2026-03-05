import 'package:MealHouse/core/app_export.dart';
import 'package:MealHouse/core/auth/user_session.dart';
import 'package:MealHouse/routes/app_routes.dart';
import 'dart:math';

class MessOwnerDashboardScreen extends StatelessWidget {
  const MessOwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fb),
      appBar: _buildAppBar(context, theme),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(theme),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(theme, 'Active Orders'),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w).copyWith(bottom: 2.h),
                child: _buildZomatoStyleOrderItem(theme, index),
              ),
              childCount: 3,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  _buildSectionHeader(theme, "Today's Menu"),
                  SizedBox(height: 2.h),
                  _buildZomatoStyleMenuCard(theme),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard_fab',
        backgroundColor: const Color(0xFFe13742),
        onPressed: () {},
        label: const Text('Update Menu', style: TextStyle(color: Colors.white)),
        icon: const CustomIconWidget(iconName: AppIcons.menu, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      backgroundColor: const Color(0xFFe13742),
      elevation: 0,
      title: Text(
        'Owner Dashboard',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Badge(
            label: const Text('3'),
            child: const CustomIconWidget(iconName: AppIcons.notifications, size: 24, color: Colors.white),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const CustomIconWidget(iconName: AppIcons.logout, color: Colors.white, size: 24),
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
        _buildZomatoStyleStatCard(
          theme,
          'Total Orders',
          '124',
          'shopping_cart',
          const Color(0xFFe13742),
        ),
        SizedBox(width: 3.w),
        _buildZomatoStyleStatCard(
          theme,
          'Revenue',
          '₹12k',
          'payments',
          const Color(0xff257e3e),
        ),
        SizedBox(width: 3.w),
        _buildZomatoStyleStatCard(
          theme,
          'Rating',
          '4.8',
          'star',
          const Color(0xff2b6ee2),
        ),
      ],
    );
  }

  Widget _buildZomatoStyleStatCard(
    ThemeData theme,
    String title,
    String value,
    String iconName,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xff586377),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Row(
        children: [
          Container(
            height: 25,
            width: 3.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color(0xFFe13742),
            ),
            margin: EdgeInsets.only(right: 2.w),
          ),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZomatoStyleOrderItem(ThemeData theme, int index) {
    final status = ['Pending', 'Preparing', 'Ready'];
    final colors = [const Color(0xfff2c418), const Color(0xff2b6ee2), const Color(0xff257e3e)];
    final customers = ['John Doe', 'Jane Smith', 'Mike Johnson'];
    final meals = ['Lunch Mini Meal', 'Dinner Full Meal', 'Breakfast Combo'];
    final times = ['12:30 PM', '7:45 PM', '8:00 AM'];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFe13742).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '#${index + 101}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFe13742),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customers[index],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      meals[index],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xff586377),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: const Color(0xff586377),
                          size: 16,
                        ),
                        SizedBox(width: 0.5.w),
                        Text(
                          times[index],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xff586377),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: colors[index].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status[index],
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors[index],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            height: 1,
            color: const Color(0xffe6e9ef),
          ),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${Random().nextInt(200) + 100}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFe13742),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View Details',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFe13742),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFe13742),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZomatoStyleMenuCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFe13742),
            const Color(0xFFf04f5f),
            const Color(0xFFea737b),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFe13742).withValues(alpha: 0.3),
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'LUNCH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const CustomIconWidget(
                  iconName: AppIcons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Dal Makhani, Jeera Rice, 3 Butter Roti, Paneer Masala, Salad, Gulab Jamun',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 3.h),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          SizedBox(height: 2.h),
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
