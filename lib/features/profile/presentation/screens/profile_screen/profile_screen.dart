import 'package:meal_house/core/app_export.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/shared/notifications/tab_change_notification.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/auth/domain/repositories/auth_repository.dart';
import 'package:meal_house/features/auth/domain/entities/user.dart';
import 'package:meal_house/features/order/domain/repositories/order_repository.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepository = sl<AuthRepository>();
  final OrderRepository _orderRepository = sl<OrderRepository>();
  
  User? _user;
  int _ordersCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final responses = await Future.wait([
        _authRepository.getCurrentUser(),
        _orderRepository.getMyOrders().catchError((_) => []),
      ]);
      
      if (mounted) {
        setState(() {
          _user = responses[0] as User;
          _ordersCount = (responses[1] as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 4.w,
                  right: 4.w,
                  top: 2.h,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(),
                    SizedBox(height: 2.h),
                    _buildStatsRow(),
                    SizedBox(height: 2.5.h),
                    _buildSectionLabel('ACCOUNT SETTINGS'),
                    SizedBox(height: 1.h),
                    _buildAccountSettingsCard(),
                    SizedBox(height: 2.5.h),
                    _buildSectionLabel('PREFERENCES'),
                    SizedBox(height: 1.h),
                    _buildPreferencesCard(),
                    SizedBox(height: 2.5.h),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary,
                size: 18,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              'Profile',
              style: GoogleFonts.lexend(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.settingsScreen),
            child: const Icon(
              Icons.settings_outlined,
              color: AppTheme.textMuted,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () async {
                final didUpdate = await Navigator.of(context).pushNamed(AppRoutes.editProfileScreen);
                if (didUpdate == true) {
                  _loadData();
                }
            },
            child: const Icon(
              Icons.edit_outlined,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3.5.h, horizontal: 5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: _user?.profileImage,
                      fit: BoxFit.cover,
                      semanticLabel: 'User Profile Picture',
                      errorWidget: Container(
                        color: AppTheme.primaryLight,
                        child: const Icon(Icons.person, size: 48, color: AppTheme.primary),
                      ),
                      placeHolder: 'assets/images/user_placeholder.png', // Or whatever generic placeholder
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          else ...[
            Text(
              _user?.fullName ?? 'Guest User',
              style: GoogleFonts.lexend(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              _user?.mobile ?? 'N/A',
              style: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 0.3.h),
            Text(
              _user?.email ?? 'N/A',
              style: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('ORDERS', _isLoading ? '-' : _ordersCount.toString(), 'Lifetime')),
        SizedBox(width: 2.w),
        Expanded(child: _buildStatCard('ACTIVE', _isLoading ? '-' : '0', 'Subscriptions')),
        SizedBox(width: 2.w),
        Expanded(child: _buildStatCard('WALLET', _isLoading ? '-' : '₹0', 'Available')),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            subtitle,
            style: GoogleFonts.publicSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 1.w),
      child: Text(
        label,
        style: GoogleFonts.publicSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    final items = [
      {'icon': Icons.shopping_bag_outlined, 'label': 'My Orders'},
      {'icon': Icons.calendar_today_outlined, 'label': 'My Subscriptions'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
      {'icon': Icons.location_on_outlined, 'label': 'Saved Locations'},
      {'icon': Icons.delivery_dining_outlined, 'label': 'Pickup Preferences'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              _buildSettingsRow(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                isOrange: true,
                onTap: () {
                  final label = item['label'] as String;
                  if (label == 'Saved Locations') {
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.savedLocationsScreen);
                  } else if (label == 'Pickup Preferences') {
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.pickupPreferencesScreen);
                  } else if (label == 'My Orders') {
                    const TabChangeNotification(1).dispatch(context);
                  } else if (label == 'My Subscriptions') {
                    const TabChangeNotification(2).dispatch(context);
                  } else if (label == 'Wallet') {
                    const TabChangeNotification(3).dispatch(context);
                  }
                },
              ),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  color: AppTheme.divider,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsRow(
            icon: Icons.notifications_outlined,
            label: 'Notification Settings',
            isOrange: false,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.notificationSettingsScreen),
          ),
          Divider(
            height: 1,
            color: AppTheme.divider,
            indent: 16,
            endIndent: 16,
          ),
          _buildSettingsRow(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            isOrange: false,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.helpSupportScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String label,
    required bool isOrange,
    required VoidCallback onTap,
  }) {
    final iconBg = isOrange
        ? AppTheme.primary.withValues(alpha: 0.1)
        : Colors.grey[100];
    final iconColor = isOrange ? AppTheme.primary : AppTheme.textSecondary;
 
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.publicSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppTheme.error, size: 22),
            SizedBox(width: 3.w),
            Text(
              'Logout',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
