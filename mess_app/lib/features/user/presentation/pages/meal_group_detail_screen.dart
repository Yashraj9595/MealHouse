import 'package:flutter/material.dart';
import '../../../../../core/app_export.dart';

class MealGroupDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? mealGroup;

  const MealGroupDetailScreen({super.key, this.mealGroup});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock data if not provided
    final data = mealGroup ?? {
      "name": "Lunch Thali Special",
      "price": 120,
      "mealType": "Lunch",
      "items": [
        {"name": "Paneer Butter Masala", "description": "Rich and creamy paneer curry"},
        {"name": "Dal Tadka", "description": "Authentic yellow lentil tempering"},
        {"name": "Jeera Rice", "description": "Cumin flavored basmati rice"},
        {"name": "Butter Tandoori Roti (3)", "description": "Whole wheat bread"},
        {"name": "Gulab Jamun", "description": "Sweet milk dumplings"},
        {"name": "Pickle & Salad", "description": "Fresh accompaniments"}
      ]
    };

    final items = data["items"] as List;
    final mealType = data["mealType"] as String?;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 25.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                data["name"] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const CustomImageWidget(
                    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const CustomIconWidget(iconName: AppIcons.back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(4.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${data["price"]}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (mealType != null) ...[
                          SizedBox(height: 0.5.h),
                          _buildMealTypeBadge(mealType),
                        ],
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const CustomIconWidget(
                            iconName: AppIcons.clock,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '20-30 min',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  'What\'s inside',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.h),
                ...items.map((item) {
                  final it = item as Map<String, dynamic>;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 0.8.h),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it["name"] as String,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (it["description"] != null)
                                Text(
                                  it["description"] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textBody,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 10.h),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: AppColors.primary),
                      onPressed: () {},
                    ),
                    const Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeBadge(String type) {
    Color color;
    IconData icon;

    switch (type.toLowerCase()) {
      case 'breakfast':
        color = Colors.orange;
        icon = Icons.wb_sunny_outlined;
        break;
      case 'lunch':
        color = Colors.blue;
        icon = Icons.light_mode_outlined;
        break;
      case 'dinner':
        color = Colors.indigo;
        icon = Icons.nights_stay_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.restaurant_menu;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 1.w),
          Text(
            type,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
