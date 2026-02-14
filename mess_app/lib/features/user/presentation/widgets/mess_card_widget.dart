import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';

class MessCardWidget extends StatelessWidget {
  final Map<String, dynamic> messData;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const MessCardWidget({
    super.key,
    required this.messData,
    required this.onTap,
    required this.onLongPress,
  });

  Color _getAvailabilityColor(String availability, ThemeData theme) {
    switch (availability) {
      case 'available':
        return theme.colorScheme.tertiary; // Usually green/success
      case 'limited':
        return Colors.orange;
      case 'sold_out':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _getAvailabilityText(String availability) {
    switch (availability) {
      case 'available':
        return 'Available';
      case 'limited':
        return 'Limited Stock';
      case 'sold_out':
        return 'Sold Out';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availability = messData['availability'] as String;
    final availabilityColor = _getAvailabilityColor(availability, theme);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CustomImageWidget(
                    imageUrl: messData['image'] as String,
                    width: double.infinity,
                    height: 20.h,
                    fit: BoxFit.cover,
                    semanticLabel: messData['semanticLabel'] as String,
                  ),
                ),
                Positioned(
                  top: 2.h,
                  right: 3.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.8.h,
                    ),
                    decoration: BoxDecoration(
                      color: availabilityColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _getAvailabilityText(availability),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (messData['isVeg'] == true)
                  Positioned(
                    top: 2.h,
                    left: 3.w,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const CustomIconWidget(
                        iconName: 'circle',
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          messData['name'] as String,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomIconWidget(
                              iconName: 'star',
                              color: Colors.amber,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              messData['rating'].toString(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.amber,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    messData['cuisine'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      const CustomIconWidget(
                        iconName: 'location_on',
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        messData['distance'] as String,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      const CustomIconWidget(
                        iconName: 'access_time',
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        messData['deliveryTime'] as String,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        messData['price'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
