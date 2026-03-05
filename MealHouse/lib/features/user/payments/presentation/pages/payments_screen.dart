import 'package:MealHouse/core/app_export.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Methods',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(theme, 'Saved Cards'),
            SizedBox(height: 2.h),
            _buildCardItem(theme, '•••• •••• •••• 4242', 'Visa', const Color(0xFF1A1F71)),
            SizedBox(height: 2.h),
            _buildCardItem(theme, '•••• •••• •••• 5555', 'MasterCard', const Color(0xFFEB001B)),
            SizedBox(height: 4.h),
            _buildSectionHeader(theme, 'UPI IDs'),
            SizedBox(height: 2.h),
            _buildUPIItem(theme, 'john.doe@okicici', 'Google Pay'),
            SizedBox(height: 2.h),
            _buildUPIItem(theme, '9876543210@paytm', 'Paytm'),
            SizedBox(height: 6.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const CustomIconWidget(iconName: AppIcons.add, color: Colors.white),
                label: const Text('Add New Payment Method'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildCardItem(ThemeData theme, String number, String type, Color color) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(iconName: AppIcons.creditCard, color: color, size: 24),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  type,
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: AppIcons.more,
            color: Colors.grey.shade400,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildUPIItem(ThemeData theme, String upiId, String provider) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const CustomIconWidget(
              iconName: AppIcons.bank,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(upiId, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(provider, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: AppIcons.delete,
            color: Colors.red.shade300,
            size: 18,
          ),
        ],
      ),
    );
  }
}
