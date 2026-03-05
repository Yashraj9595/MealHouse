import 'package:intl/intl.dart';
import 'package:MealHouse/core/app_export.dart';
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

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: const Color(0xFFe13742), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Order ID and Status
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFe13742).withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: Text(
                          '#${order.id.substring(3)}',
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
                            order.id,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            timeAgoStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xff586377),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildZomatoStyleStatusBadge(context, order.status),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  height: 1,
                  color: const Color(0xffe6e9ef),
                ),
                SizedBox(height: 2.h),

                // Customer info
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFe13742).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          order.customerName.isNotEmpty
                              ? order.customerName[0].toUpperCase()
                              : '?',
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
                            order.customerName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            order.customerPhone,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xff586377),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onCall != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xff257e3e).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.phone,
                            color: Color(0xff257e3e),
                            size: 20,
                          ),
                          onPressed: onCall,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),

                // Items section
                if (hasItems) ...[
                  Text(
                    'Items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff586377),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: const Color(0xfff5f6fb),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ...orderItems!.take(2).map((item) {
                          final qty = item['quantity'] as int? ?? 1;
                          final name = item['name'] as String? ?? '';
                          final price = (item['price'] as num?)?.toDouble() ?? 0;
                          final lineTotal = price * qty;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 0.5.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${qty}x $name',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  '₹${lineTotal.toStringAsFixed(0)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (orderItems!.length > 2)
                          Padding(
                            padding: EdgeInsets.only(top: 0.5.h),
                            child: Text(
                              '+${orderItems!.length - 2} more items',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xff586377),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: const Color(0xfff5f6fb),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.mealName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                SizedBox(height: 2.h),

                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xff586377),
                      ),
                    ),
                    Text(
                      '₹${order.price.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFe13742),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Action buttons
                if (!isBulkSelectionMode &&
                    order.status == OrderStatus.pending &&
                    (onReject != null || onAccept != null)) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      if (onReject != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xffe02b2b)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Reject',
                              style: TextStyle(
                                color: const Color(0xffe02b2b),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (onReject != null && onAccept != null) SizedBox(width: 3.w),
                      if (onAccept != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFe13742),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Accept',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],

                // Other status actions
                if (!isBulkSelectionMode &&
                    order.status != OrderStatus.pending &&
                    (onMarkReady != null || onMarkDelivered != null)) ...[
                  SizedBox(height: 2.h),
                  if (order.status == OrderStatus.preparing && onMarkReady != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onMarkReady,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2b6ee2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Mark Ready',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else if (order.status == OrderStatus.ready && onMarkDelivered != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onMarkDelivered,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff257e3e),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Mark Delivered',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZomatoStyleStatusBadge(BuildContext context, OrderStatus status) {
    Color color;
    String label;

    switch (status) {
      case OrderStatus.pending:
        color = const Color(0xfff2c418);
        label = "Pending";
        break;
      case OrderStatus.preparing:
        color = const Color(0xff2b6ee2);
        label = "Confirmed";
        break;
      case OrderStatus.ready:
        color = const Color(0xff257e3e);
        label = "Ready";
        break;
      case OrderStatus.delivered:
        color = const Color(0xFFe13742);
        label = "Delivered";
        break;
      case OrderStatus.cancelled:
        color = const Color(0xffe02b2b);
        label = "Cancelled";
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
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
