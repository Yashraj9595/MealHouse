import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/app_export.dart';
import '../../../../../core/auth/user_session.dart';
import '../../../../../routes/app_routes.dart';
import '../state/user_profile_providers.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: userProfileAsync.when(
        data: (profile) => SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(context, theme, profile),
              SizedBox(height: 2.h),
              _buildProfileOptions(context, theme),
              SizedBox(height: 4.h),
              _buildLogoutButton(context, theme),
              SizedBox(height: 4.h),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme, UserProfileEntity profile) {
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 10.h, 6.w, 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: const Color(0xFFE8F5E9),
            child: CustomIconWidget(
              iconName: AppIcons.profile,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeader,
                  ),
                ),
                Text(
                  profile.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textBody,
                  ),
                ),
                SizedBox(height: 1.5.h),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfileScreen),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          _buildOptionTile(
            context,
            theme,
            'My Addresses',
            AppIcons.location,
            () => Navigator.pushNamed(context, AppRoutes.addressScreen),
          ),
          _buildOptionTile(
            context,
            theme,
            'Payment Methods',
            AppIcons.creditCard,
            () => Navigator.pushNamed(context, AppRoutes.paymentsScreen),
          ),
          _buildOptionTile(
            context,
            theme,
            'Subscriptions',
            AppIcons.calendar,
            () => Navigator.pushNamed(context, AppRoutes.subscriptionScreen),
          ),
          _buildOptionTile(
            context,
            theme,
            'Settings',
            AppIcons.settings,
            () => Navigator.pushNamed(context, AppRoutes.settingsScreen),
          ),
          _buildOptionTile(
            context,
            theme,
            'Help & Support',
            AppIcons.help,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    ThemeData theme,
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppColors.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textHeader,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: AppIcons.chevronRight,
        color: Colors.grey.shade400,
        size: 20,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: () {
          UserSession().logout();
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              iconName: AppIcons.logout,
              color: Colors.red,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Logout',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
