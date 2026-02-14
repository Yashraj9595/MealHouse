import 'package:flutter/material.dart';
import '../../../../../core/app_export.dart';

/// Info section displaying address, hours, contact, and certifications
class InfoSectionWidget extends StatelessWidget {
  final Map<String, dynamic> messData;
  final VoidCallback onMapTap;
  final VoidCallback onCallTap;

  const InfoSectionWidget({
    super.key,
    required this.messData,
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
            content: messData["address"] as String,
            actionIcon: 'directions',
            onActionTap: onMapTap,
          ),
          SizedBox(height: 2.h),
          _buildInfoCard(
            context: context,
            icon: 'access_time',
            title: "Operating Hours",
            content: messData["operatingHours"] as String,
          ),
          SizedBox(height: 2.h),
          _buildInfoCard(
            context: context,
            icon: 'phone',
            title: "Contact",
            content: messData["contact"] as String,
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
                  ...(messData["certifications"] as List).map((cert) {
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
                              cert as String,
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
