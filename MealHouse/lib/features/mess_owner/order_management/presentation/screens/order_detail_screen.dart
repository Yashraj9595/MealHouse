import 'package:MealHouse/core/app_export.dart';
import '../../domain/entities/order_entity.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Order Details", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(order.status),
            SizedBox(height: 3.h),
            _buildSection(
              theme,
              "Customer Info",
              Column(
                children: [
                  _buildDetailRow(AppIcons.profile, "Name", order.customerName),
                  _buildDetailRow(AppIcons.phone, "Phone", order.customerPhone),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            _buildSection(
              theme,
              "Meal Info",
              Column(
                children: [
                  _buildDetailRow(AppIcons.menu, "Item", order.mealName),
                  _buildDetailRow(AppIcons.payments, "Price", "₹${order.price}"),
                  if (order.specialInstructions != null)
                    _buildDetailRow(AppIcons.infoOutline, "Instructions", order.specialInstructions!),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(OrderStatus status) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const CustomIconWidget(iconName: AppIcons.checkGroup, color: Colors.white, size: 48),
          SizedBox(height: 2.h),
          Text(
            "Order is ${status.name.toUpperCase()}",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1.h),
          Text(
            "Order ID: ${order.id}",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          CustomIconWidget(iconName: icon, color: AppColors.primary, size: 20),
          SizedBox(width: 3.w),
          Text(
            "$label:",
            style: const TextStyle(color: AppColors.textBody, fontSize: 14),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textHeader, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    String nextStatusLabel = "";
    Color btnColor = AppColors.primary;

    if (order.status == OrderStatus.pending) {
      nextStatusLabel = "Accept & Start Preparing";
    } else if (order.status == OrderStatus.preparing) {
      nextStatusLabel = "Mark as Ready";
    } else if (order.status == OrderStatus.ready) {
      nextStatusLabel = "Confirm Delivery";
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Logic to update status
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(nextStatusLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(height: 2.h),
        if (order.status == OrderStatus.pending)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              child: const Text("Reject Order", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}
