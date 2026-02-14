import 'package:flutter/material.dart';
import '../../../../../core/app_export.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;
  bool _smsUpdates = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          _buildSectionHeader(theme, 'Notifications'),
          _buildSwitchTile(
            'Push Notifications',
            'Receive real-time order updates',
            _pushNotifications,
            (v) => setState(() => _pushNotifications = v),
          ),
          _buildSwitchTile(
            'Email Updates',
            'Weekly digests and special offers',
            _emailUpdates,
            (v) => setState(() => _emailUpdates = v),
          ),
          _buildSwitchTile(
            'SMS Updates',
            'Delivery confirmation via SMS',
            _smsUpdates,
            (v) => setState(() => _smsUpdates = v),
          ),
          SizedBox(height: 3.h),
          _buildSectionHeader(theme, 'App Settings'),
          _buildSwitchTile(
            'Dark Mode',
            'Switch to dark theme',
            _darkMode,
            (v) => setState(() => _darkMode = v),
          ),
          _buildNavigationTile(
            theme,
            'Language',
            'English (US)',
            AppIcons.language,
          ),
          SizedBox(height: 3.h),
          _buildSectionHeader(theme, 'Security & Account'),
          _buildNavigationTile(
            theme,
            'Privacy Policy',
            'Review our data policies',
            AppIcons.security,
          ),
          _buildNavigationTile(
            theme,
            'Terms of Service',
            'Read user agreements',
            AppIcons.infoOutline,
          ),
          SizedBox(height: 4.h),
          Center(
            child: Text(
              'App Version: 1.0.2',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 1.h),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String sub, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
    );
  }

  Widget _buildNavigationTile(ThemeData theme, String title, String sub, String iconName) {
    return ListTile(
      leading: CustomIconWidget(iconName: iconName, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const CustomIconWidget(iconName: AppIcons.chevronRight, size: 20, color: Colors.grey),
      onTap: () {},
      contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
    );
  }
}
