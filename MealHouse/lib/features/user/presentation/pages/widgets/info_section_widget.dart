import 'package:MealHouse/core/app_export.dart';
import 'package:MealHouse/features/user/data/models/mess_model.dart';

/// Info section displaying address, hours, contact, and certifications
class InfoSectionWidget extends StatelessWidget {
  final MessModel messModel;
  final VoidCallback onMapTap;
  final VoidCallback onCallTap;

  const InfoSectionWidget({
    super.key,
    required this.messModel,
    required this.onMapTap,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context: context,
            icon: 'location_on',
            title: "Address",
            content: messModel.distance, // Use distance or full address if available
            actionIcon: 'directions',
            onActionTap: onMapTap,
          ),
          SizedBox(height: 2.h),
          _buildInfoCard(
            context: context,
            icon: 'access_time',
            title: "Operating Hours",
            content: messModel.deliveryTime, // Use actual hours if added to model
          ),
          SizedBox(height: 2.h),
          _buildInfoCard(
            context: context,
            icon: 'phone',
            title: "Contact",
            content: "N/A", // Updating phone property if needed
            actionIcon: 'call',
            onActionTap: onCallTap,
          ),
          SizedBox(height: 2.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'verified',
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "Certifications",
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  ...["Certified Kitchen", "Health Safety Approved"].map((cert) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              cert,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String icon,
    required String title,
    required String content,
    String? actionIcon,
    VoidCallback? onActionTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  SizedBox(height: 0.5.h),
                  Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (actionIcon != null && onActionTap != null)
              IconButton(
                icon: CustomIconWidget(
                  iconName: actionIcon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                onPressed: onActionTap,
              ),
          ],
        ),
      ),
    );
  }
}
