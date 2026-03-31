import 'package:flutter/material.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/admin/presentation/screens/admin_home.dart';
import 'package:meal_house/features/mess_owner/presentation/mess_owner_navigation_wrapper.dart';
import 'package:meal_house/features/user/main_navigation_wrapper.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Developer Options'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select User Role to Bypass Login',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildRoleButton(
                context,
                'User App',
                'Discovery, Orders, & Profile',
                Icons.person,
                AppTheme.primary,
                const MainNavigationWrapper(),
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                context,
                'Mess Owner App',
                'Menu Management & Orders',
                Icons.restaurant_menu,
                Colors.green[700]!,
                const MessOwnerNavigationWrapper(),
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                context,
                'Admin App',
                'System Stats & User Management',
                Icons.admin_panel_settings,
                Colors.blueGrey[900]!,
                const AdminHomeScreen(),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              const Text(
                'Test Account Credentials',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildCredentialCard('Admin', 'admin@mealhouse.com', 'admin123'),
              const SizedBox(height: 8),
              _buildCredentialCard('Owner', 'owner@mealhouse.com', 'owner123'),
              const SizedBox(height: 8),
              _buildCredentialCard('User', 'user@mealhouse.com', 'user123'),
              const SizedBox(height: 24),
              const Text(
                'Note: This page is for development only.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget target,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => target),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.2), width: 2),
        ),
        elevation: 4,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildCredentialCard(String role, String email, String password) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              role[0],
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('Pass: $password', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              // Note: Clipboard is not available in all environments, 
              // but this is standard Flutter code for it.
            },
          ),
        ],
      ),
    );
  }
}
