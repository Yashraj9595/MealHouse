import 'package:flutter/material.dart';
import 'package:MealHouse/core/app_export.dart';
import 'package:MealHouse/features/user/data/models/mess_model.dart';
import 'mess_card_widget.dart';

class FeaturedMessWidget extends StatelessWidget {
  final List<MessModel> featuredMesses;
  final Function(MessModel) onMessTap;

  const FeaturedMessWidget({
    super.key,
    required this.featuredMesses,
    required this.onMessTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 28.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'local_fire_department',
                  color: Colors.orange,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Featured Messes',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to all featured messes
                  },
                  child: Text(
                    'See All',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: featuredMesses.length,
              itemBuilder: (context, index) {
                final mess = featuredMesses[index];
                return Container(
                  width: 40.w,
                  margin: EdgeInsets.only(right: 3.w),
                  child: MessCardWidget(
                    messModel: mess,
                    onTap: () => onMessTap(mess),
                    onLongPress: () {
                      // Show mess options
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
