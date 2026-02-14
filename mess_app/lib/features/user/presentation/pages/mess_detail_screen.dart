import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../routes/app_routes.dart';
import './widgets/info_section_widget.dart';
import './widgets/meal_group_card_widget.dart';
import './widgets/mess_header_widget.dart';
import './widgets/reviews_section_widget.dart';

class MessDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? mess; 
  const MessDetailScreen({super.key, this.mess});

  @override
  State<MessDetailScreen> createState() => _MessDetailScreenState();
}

class _MessDetailScreenState extends State<MessDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;

  final Map<String, dynamic> _messData = {
    "id": 1,
    "name": "Shree Krishna Mess",
    "coverImage":
        "https://img.rocket.new/generatedImages/rocket_gen_img_17d57445d-1765978187975.png",
    "coverImageLabel":
        "Traditional Indian thali with multiple curry bowls, rice, roti, and accompaniments served on a steel plate",
    "rating": 4.5,
    "totalReviews": 328,
    "cuisineType": "North Indian, South Indian",
    "isOpen": true,
    "address": "123, MG Road, Near City Mall, Bangalore - 560001",
    "operatingHours": "Mon-Sun: 7:00 AM - 10:00 PM",
    "contact": "+91 98765 43210",
    "certifications": [
      "FSSAI Certified",
      "ISO 22000:2018",
      "Hygiene Rating: 5/5",
    ],
    "mealGroups": [
      {
        "id": 1,
        "name": "Lunch Thali",
        "mealType": "Lunch",
        "priceRange": "₹80 - ₹120",
        "items": [
          {
            "name": "Standard Thali",
            "description": "2 Rotis, Dal, Rice, Sabzi, Salad, Pickle",
            "price": 80,
            "isVeg": true,
            "available": true,
          },
          {
            "name": "Special Thali",
            "description": "3 Rotis, Dal, Rice, 2 Sabzi, Raita, Sweet, Salad",
            "price": 120,
            "isVeg": true,
            "available": true,
          },
          {
            "name": "Mini Thali",
            "description": "1 Roti, Dal, Rice, Sabzi",
            "price": 60,
            "isVeg": true,
            "available": false,
          },
        ],
      },
      {
        "id": 2,
        "name": "Dinner Special",
        "mealType": "Dinner",
        "priceRange": "₹90 - ₹150",
        "items": [
          {
            "name": "Regular Dinner",
            "description": "3 Rotis, Dal, Rice, Sabzi, Curd",
            "price": 90,
            "isVeg": true,
            "available": true,
          },
          {
            "name": "Premium Dinner",
            "description": "4 Rotis, Dal, Rice, Paneer Sabzi, Raita, Sweet",
            "price": 150,
            "isVeg": true,
            "available": true,
          },
        ],
      },
      {
        "id": 3,
        "name": "Breakfast Combo",
        "mealType": "Breakfast",
        "priceRange": "₹40 - ₹80",
        "items": [
          {
            "name": "Idli Sambar",
            "description": "4 Idlis with Sambar and Chutney",
            "price": 40,
            "isVeg": true,
            "available": true,
          },
          {
            "name": "Dosa Combo",
            "description": "2 Masala Dosas with Sambar and Chutney",
            "price": 60,
            "isVeg": true,
            "available": true,
          },
          {
            "name": "Poha Upma",
            "description": "Poha or Upma with Tea",
            "price": 50,
            "isVeg": true,
            "available": true,
          },
        ],
      },
    ],
    "ratingBreakdown": {"5": 200, "4": 80, "3": 30, "2": 12, "1": 6},
    "reviews": [
      {
        "userName": "Rajesh Kumar",
        "rating": 5,
        "date": "2 days ago",
        "comment":
            "Excellent food quality and taste. The lunch thali is amazing with authentic home-style cooking. Highly recommended for daily meals!",
      },
      {
        "userName": "Priya Sharma",
        "rating": 4,
        "date": "1 week ago",
        "comment":
            "Good variety and reasonable prices. The special thali is worth every penny. Only suggestion would be to add more sweet options.",
      },
      {
        "userName": "Amit Patel",
        "rating": 5,
        "date": "2 weeks ago",
        "comment":
            "Best mess in the area! Clean, hygienic, and delicious food. The staff is very friendly and service is quick.",
      },
    ],
  };

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

  void _handleCallTap() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${_messData["contact"]}...'),
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

    return Scaffold(
      body: Column(
        children: [
          MessHeaderWidget(
            messData: _messData,
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
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Menu updated'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    itemCount: (_messData["mealGroups"] as List).length,
                    itemBuilder: (context, index) {
                      final mealGroup =
                          (_messData["mealGroups"] as List)[index]
                              as Map<String, dynamic>;
                      return MealGroupCardWidget(
                        mealGroup: mealGroup,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(AppRoutes.mealGroupDetailScreen);
                        },
                      );
                    },
                  ),
                ),
                InfoSectionWidget(
                  messData: _messData,
                  onMapTap: _handleMapTap,
                  onCallTap: _handleCallTap,
                ),
                ReviewsSectionWidget(messData: _messData),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
            onPressed: (_messData["isOpen"] as bool) ? _handleOrderNow : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              (_messData["isOpen"] as bool) ? "Order Now" : "Currently Closed",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
