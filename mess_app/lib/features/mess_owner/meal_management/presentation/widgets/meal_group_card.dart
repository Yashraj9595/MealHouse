import 'package:flutter/material.dart';
import 'package:MealHouse/core/app_export.dart';
import '../../domain/entities/meal_group_entity.dart';

class MealGroupCard extends StatelessWidget {
  final MealGroupEntity group;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggleStatus;

  const MealGroupCard({
    super.key,
    required this.group,
    required this.onEdit,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          if (group.imageUrl != null && group.imageUrl!.isNotEmpty)
            SizedBox(
              height: 18.h,
              width: double.infinity,
              child: ClipRect(
                child: Image.network(
                  group.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Items:",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textBody,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    _buildMealTypeBadge(group.mealType),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  group.itemsDescription.isEmpty ? "No items listed" : group.itemsDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHeader,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.textBody),
                        SizedBox(width: 1.w),
                        Text(
                          "Available: ",
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textBody),
                        ),
                        Text(
                          "${group.availableQuantity}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (group.videoUrl != null && group.videoUrl!.isNotEmpty)
                      const Icon(Icons.play_circle_outline, color: AppColors.primary, size: 20),
                  ],
                ),
                SizedBox(height: 1.5.h),
                const Divider(height: 1),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          group.isActive ? "Active" : "Inactive",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: group.isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: group.isActive,
                            onChanged: onToggleStatus,
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text("Edit"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
      decoration: BoxDecoration(
        color: group.isActive ? AppColors.primary : Colors.grey[400],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              group.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "₹${group.price.toStringAsFixed(0)}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeBadge(MealType type) {
    Color color;
    IconData icon;

    switch (type) {
      case MealType.breakfast:
        color = Colors.orange;
        icon = Icons.wb_sunny_outlined;
        break;
      case MealType.lunch:
        color = Colors.blue;
        icon = Icons.light_mode_outlined;
        break;
      case MealType.dinner:
        color = Colors.indigo;
        icon = Icons.nights_stay_outlined;
        break;
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
          Icon(icon, size: 12, color: color),
          SizedBox(width: 1.w),
          Text(
            type.name,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
