import 'package:flutter/services.dart';
import 'package:MealHouse/core/app_export.dart';
import 'package:MealHouse/routes/app_routes.dart';
import 'package:MealHouse/features/user/data/models/mess_model.dart';
import './widgets/info_section_widget.dart';
import './widgets/meal_group_card_widget.dart';
import './widgets/mess_header_widget.dart';
import './widgets/reviews_section_widget.dart';

class MessDetailScreen extends StatefulWidget {
  final MessModel mess; 
  const MessDetailScreen({super.key, required this.mess});

  @override
  State<MessDetailScreen> createState() => _MessDetailScreenState();
}

class _MessDetailScreenState extends State<MessDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;

  // Mock data for reviews (as they aren't fully in the model yet)
  final List<Map<String, dynamic>> _mockReviews = [
      {
        "userName": "Rajesh Kumar",
        "rating": 5,
        "date": "2 days ago",
        "comment":
            "Excellent food quality and taste. The lunch thali is amazing with authentic home-style cooking. Highly recommended for daily meals!",
      },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBackPressed() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  void _handleSharePressed() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality will be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleFavoritePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleMapTap() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening maps...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleCallTap(MessModel mess) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling (Contact not available)...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleOrderNow() {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed(AppRoutes.mealGroupDetailScreen);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mess = widget.mess;

    return Scaffold(
      body: Column(
        children: [
          MessHeaderWidget(
            messModel: mess,
            onBackPressed: _handleBackPressed,
            onSharePressed: _handleSharePressed,
            onFavoritePressed: _handleFavoritePressed,
            isFavorite: _isFavorite,
          ),
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Menu"),
                Tab(text: "Info"),
                Tab(text: "Reviews"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    // Refresh the mess data if needed
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    itemCount: mess.mealGroups.length,
                    itemBuilder: (context, index) {
                      final mealGroup = mess.mealGroups[index];
                      return MealGroupCardWidget(
                        mealGroup: mealGroup,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(AppRoutes.mealGroupDetailScreen, arguments: mealGroup);
                        },
                      );
                    },
                  ),
                ),
                InfoSectionWidget(
                  messModel: mess,
                  onMapTap: _handleMapTap,
                  onCallTap: () => _handleCallTap(mess),
                ),
                ReviewsSectionWidget(messData: {
                  "rating": mess.rating,
                  "totalReviews": "100+",
                  "ratingBreakdown": {"5": 70, "4": 20, "3": 5, "2": 3, "1": 2},
                  "reviews": _mockReviews,
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme, mess),
    );
  }

  Widget _buildBottomBar(ThemeData theme, MessModel mess) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: mess.isActive ? _handleOrderNow : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            mess.isActive ? "Order Now" : "Currently Closed",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
