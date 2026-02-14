import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MealHouse/core/app_export.dart';
import 'package:sizer/sizer.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/entities/order_entity.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderEntity order;
  final List<Map<String, dynamic>>? orderItems;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMarkReady;
  final VoidCallback? onMarkDelivered;
  final VoidCallback? onCall;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isBulkSelectionMode;

  const OrderCardWidget({
    super.key,
    required this.order,
    this.orderItems,
    required this.onTap,
    this.onAccept,
    this.onReject,
    this.onMarkReady,
    this.onMarkDelivered,
    this.onCall,
    this.onLongPress,
    this.isSelected = false,
    this.isBulkSelectionMode = false,
  });

  static String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgoStr = _timeAgo(order.orderTime);
    final hasItems = orderItems != null && orderItems!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Order ID + time (left), Status (right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          timeAgoStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, order.status),
                ],
              ),
              SizedBox(height: 2.h),
              // Customer row: avatar, name, phone icon
              Row(
                children: [
                  Container(
                    width: 9.w,
                    height: 9.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      order.customerName.isNotEmpty
                          ? order.customerName[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onCall != null)
                    InkWell(
                      onTap: onCall,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: EdgeInsets.all(1.w),
                        child: CustomIconWidget(
                          iconName: AppIcons.phone,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 2.h),
              // Items section
              if (hasItems) ...[
                Text(
                  'Items',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 0.8.h),
                ...orderItems!.map((item) {
                  final qty = item['quantity'] as int? ?? 1;
                  final name = item['name'] as String? ?? '';
                  final price = (item['price'] as num?)?.toDouble() ?? 0;
                  final lineTotal = price * qty;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 0.5.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${qty}x $name',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '₹${lineTotal.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 1.h),
              ] else ...[
                Text(
                  order.mealName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
              ],
              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '₹${order.price.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Reject / Accept buttons (for pending)
              if (!isBulkSelectionMode &&
                  order.status == OrderStatus.pending &&
                  (onReject != null || onAccept != null)) ...[
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (onReject != null)
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: 'Reject',
                          color: AppColors.error,
                          onTap: onReject!,
                          isOutlined: true,
                        ),
                      ),
                    if (onReject != null && onAccept != null) SizedBox(width: 3.w),
                    if (onAccept != null)
                      Expanded(
                        child: _buildActionButton(
                          context,
                          label: 'Accept',
                          color: AppColors.primary,
                          onTap: onAccept!,
                        ),
                      ),
                  ],
                ),
              ],
              // Other status actions (Mark Ready / Mark Delivered)
              if (!isBulkSelectionMode &&
                  order.status != OrderStatus.pending &&
                  (onMarkReady != null || onMarkDelivered != null)) ...[
                SizedBox(height: 2.h),
                if (order.status == OrderStatus.preparing && onMarkReady != null)
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      context,
                      label: 'Mark Ready',
                      color: AppColors.info,
                      onTap: onMarkReady!,
                    ),
                  )
                else if (order.status == OrderStatus.ready && onMarkDelivered != null)
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      context,
                      label: 'Mark Delivered',
                      color: AppColors.success,
                      onTap: onMarkDelivered!,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    Color color;
    String label;
    bool showDot = false;

    switch (status) {
      case OrderStatus.pending:
        color = AppColors.error;
        label = "Pending";
        showDot = true;
        break;
      case OrderStatus.preparing:
        color = AppColors.info;
        label = "Confirmed";
        break;
      case OrderStatus.ready:
        color = AppColors.success;
        label = "Ready";
        break;
      case OrderStatus.delivered:
        color = AppColors.primary;
        label = "Delivered";
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        label = "Cancelled";
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 1.5.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return Material(
      color: isOutlined ? Colors.transparent : color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isOutlined ? Border.all(color: color) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isOutlined ? color : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
            ),
          ),
        ),
      ),
    );
  }
}
