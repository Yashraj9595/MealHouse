import 'package:MealHouse/core/app_export.dart';

class MessInfoCard extends StatelessWidget {
  final String messName;
  final String address;
  final String operatingHours;
  final bool isVegOnly;
  final String phoneNumber;

  const MessInfoCard({
    super.key,
    required this.messName,
    required this.address,
    required this.operatingHours,
    required this.isVegOnly,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  messName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeader,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isVegOnly ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: AppIcons.circle,
                      color: isVegOnly ? Colors.green : Colors.red,
                      size: 10,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      isVegOnly ? "Veg Only" : "Veg & Non-Veg",
                      style: TextStyle(
                        color: isVegOnly ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(AppIcons.location, address),
          SizedBox(height: 1.5.h),
          _buildInfoRow(AppIcons.clock, operatingHours),
          SizedBox(height: 1.5.h),
          _buildInfoRow(AppIcons.phone, phoneNumber),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomIconWidget(iconName: icon, color: AppColors.primary, size: 20),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textBody,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
