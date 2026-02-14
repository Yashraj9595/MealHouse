import 'package:flutter/material.dart';
import '../../../../../core/app_export.dart';

/// Expandable meal card showing meal details and items
class MealGroupCardWidget extends StatefulWidget {
  final Map<String, dynamic> mealGroup;
  final VoidCallback onTap;

  const MealGroupCardWidget({
    super.key,
    required this.mealGroup,
    required this.onTap,
  });

  @override
  State<MealGroupCardWidget> createState() => _MealGroupCardWidgetState();
}

class _MealGroupCardWidgetState extends State<MealGroupCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = widget.mealGroup["items"] as List;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mealGroup["name"] as String,
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "${items.length} items • ${widget.mealGroup["priceRange"]}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Column(
              children: items.map((item) {
                final itemMap = item as Map<String, dynamic>;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: theme.dividerColor, width: 1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: EdgeInsets.only(top: 1.h),
                        decoration: BoxDecoration(
                          color: (itemMap["isVeg"] as bool)
                              ? Colors.green
                              : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemMap["name"] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (itemMap["description"] != null) ...[
                              SizedBox(height: 0.5.h),
                              Text(
                                itemMap["description"] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                Text(
                                  "₹${itemMap["price"]}",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (itemMap["available"] as bool)
                                        ? theme.colorScheme.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : theme.colorScheme.error.withValues(
                                            alpha: 0.1,
                                          ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    (itemMap["available"] as bool)
                                        ? "Available"
                                        : "Out of Stock",
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: (itemMap["available"] as bool)
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
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
              }).toList(),
            ),
        ],
      ),
    );
  }
}
