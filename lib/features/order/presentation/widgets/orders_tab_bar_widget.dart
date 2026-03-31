import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class OrdersTabBarWidget extends StatelessWidget {
  final TabController tabController;
  final int selectedIndex;
  final ValueChanged<int> onTabTap;

  const OrdersTabBarWidget({
    super.key,
    required this.tabController,
    required this.selectedIndex,
    required this.onTabTap,
  });

  static const List<String> _tabs = [
    'Active',
    'Upcoming',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            labelPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: AppTheme.primary, width: 2.5),
              insets: EdgeInsets.symmetric(horizontal: 4),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
            unselectedLabelStyle: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            onTap: onTabTap,
            tabs: _tabs
                .map((label) => Tab(height: 44, child: Text(label)))
                .toList(),
          ),
          Container(height: 1, color: AppTheme.divider),
        ],
      ),
    );
  }
}
