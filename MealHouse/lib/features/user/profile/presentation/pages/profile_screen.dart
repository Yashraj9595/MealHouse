import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/core/app_export.dart';
import 'package:MealHouse/core/auth/user_session.dart';
import 'package:MealHouse/routes/app_routes.dart';
import 'package:MealHouse/core/network/api_client.dart';
import '../state/user_profile_providers.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserProfileEntity? _profile;
  bool _isLoading = false;
  String? _error;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    // Initialize with mock data for instant display
    _profile = UserProfileEntity(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      address: '123 Main St, Bangalore, Karnataka 560001',
    );
    // Load real data in background
    _loadProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiClient.get('/auth/me');
      
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data['user'] ?? response.data;
        setState(() {
          _profile = UserProfileEntity(
            id: data['_id'] ?? data['id'] ?? '1',
            name: data['name'] ?? 'John Doe',
            email: data['email'] ?? 'john.doe@example.com',
            phoneNumber: data['phone']?.toString() ?? '+1234567890',
            address: data['address']?['street'] != null 
                ? '${data['address']['street']}, ${data['address']['city']}, ${data['address']['state']} ${data['address']['pincode']}'
                : '123 Main St, Bangalore, Karnataka 560001',
          );
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _profile == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(context, theme, _profile!),
                SliverToBoxAdapter(child: SizedBox(height: 3.h)),
                _buildStatsSection(theme),
                SliverToBoxAdapter(child: SizedBox(height: 3.h)),
                _buildProfileSections(context, theme),
                SliverToBoxAdapter(child: SizedBox(height: 4.h)),
                if (_error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'warning',
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                'Using offline data',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadProfile,
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, ThemeData theme, UserProfileEntity profile) {
    return SliverAppBar(
      expandedHeight: 28.h,
      pinned: true,
      backgroundColor: const Color(0xFFe13742),
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFe13742),
                    const Color(0xFFf04f5f),
                    const Color(0xFFea737b),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8.h,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: CustomIconWidget(
                        iconName: AppIcons.profile,
                        size: 45,
                        color: const Color(0xFFe13742),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    profile.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profile.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(theme, '12', 'Total Orders'),
              Container(height: 4.h, width: 1, color: Colors.grey.withValues(alpha: 0.2)),
              _buildStatItem(theme, '1', 'Active Sub'),
              Container(height: 4.h, width: 1, color: Colors.grey.withValues(alpha: 0.2)),
              _buildStatItem(theme, '4.8', 'Rating'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSections(BuildContext context, ThemeData theme) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(height: 2.h),
          // Zomato-style quick actions
          _buildQuickActions(theme),
          SizedBox(height: 2.h),
          _buildGroupHeader(theme, 'Account Settings'),
          _buildModernTile(
            context,
            'Your profile',
            'person_outline',
            () => Navigator.pushNamed(context, AppRoutes.editProfileScreen),
            extraWidget: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffeaffee),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "100% completed",
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 12,
                  color: const Color(0xff257e3e),
                ),
              ),
            ),
          ),
          _buildModernTile(
            context,
            'Your rating',
            'star',
            () {},
            extraWidget: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xfff3f4f8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Text(
                    "4.8",
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 14,
                      color: const Color(0xff9296a5),
                    ),
                  ),
                  const Icon(
                    Icons.star,
                    size: 14,
                    color: Color(0xff9296a5),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          _buildFoodOrdersSection(theme),
          SizedBox(height: 2.h),
          _buildCouponsSection(theme),
          SizedBox(height: 2.h),
          _buildMoneySection(theme),
          SizedBox(height: 2.h),
          _buildMoreSection(theme),
        ]),
      ),
    );
  }

  Widget _buildGroupHeader(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 1.h),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildModernTile(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap, {
    Widget? extraWidget,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            splashColor: const Color(0xffe6e9ef),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xfff3f4f8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: CustomIconWidget(
                        iconName: iconName,
                        color: const Color(0xff9296a5),
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (extraWidget != null) extraWidget,
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xff9296a5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Row(
      children: [
        _buildClickableIconLabel(
          label: "Likes",
          iconName: 'favorite',
          onClick: () {
            // TODO: Navigate to likes
          },
          theme: theme,
        ),
        SizedBox(width: 3.w),
        _buildClickableIconLabel(
          label: "Payments",
          iconName: 'payment',
          onClick: () {
            Navigator.pushNamed(context, AppRoutes.paymentsScreen);
          },
          theme: theme,
        ),
        SizedBox(width: 3.w),
        _buildClickableIconLabel(
          label: "Settings",
          iconName: 'settings',
          onClick: () {
            Navigator.pushNamed(context, AppRoutes.settingsScreen);
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildClickableIconLabel({
    required String label,
    required String iconName,
    required VoidCallback onClick,
    required ThemeData theme,
  }) =>
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: onClick,
              splashColor: const Color(0xffe6e9ef),
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: iconName,
                      color: const Color(0xFFe13742),
                      size: 25,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildSectionHeader({
    required String title,
    required ThemeData theme,
  }) =>
      Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            Container(
              height: 25,
              width: 3.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color(0xFFe13742),
              ),
              margin: EdgeInsets.only(right: 2.w),
            ),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(fontSize: 16),
            ),
          ],
        ),
      );

  Widget _addBorderSection(Widget widget) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: Colors.white,
          child: widget,
        ),
      );

  Widget _buildFoodOrdersSection(ThemeData theme) => _addBorderSection(
        Column(
          children: [
            _buildSectionHeader(title: "Food Orders", theme: theme),
            _buildModernTile(
              context,
              "Your orders",
              'delivery_dining',
              () {
                // TODO: Navigate to orders
              },
            ),
            _buildModernTile(
              context,
              "Favorite orders",
              'favorite',
              () {
                // TODO: Navigate to favorite orders
              },
            ),
            _buildModernTile(
              context,
              "Address book",
              AppIcons.location,
              () => Navigator.pushNamed(context, AppRoutes.addressScreen),
            ),
            _buildModernTile(
              context,
              "Hidden Messes",
              'visibility_off',
              () {
                // TODO: Navigate to hidden messes
              },
            ),
            _buildModernTile(
              context,
              "Online ordering help",
              'support_agent',
              () {
                // TODO: Navigate to help
              },
            ),
          ],
        ),
      );

  Widget _buildCouponsSection(ThemeData theme) => _addBorderSection(
        Column(
          children: [
            _buildSectionHeader(title: "Coupons", theme: theme),
            _buildModernTile(
              context,
              "Collected coupons",
              'local_offer',
              () {
                // TODO: Navigate to coupons
              },
              extraWidget: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffffedef),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "new",
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    color: const Color(0xFFe13742),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildMoneySection(ThemeData theme) => _addBorderSection(
        Column(
          children: [
            _buildSectionHeader(title: "Money", theme: theme),
            _buildModernTile(
              context,
              "Buy Gift Card",
              'card_giftcard',
              () {
                // TODO: Navigate to buy gift card
              },
            ),
            _buildModernTile(
              context,
              "Claim Gift Card",
              'redeem',
              () {
                // TODO: Navigate to claim gift card
              },
            ),
            _buildModernTile(
              context,
              "Gift Card order history",
              'history',
              () {
                // TODO: Navigate to gift card history
              },
            ),
            _buildModernTile(
              context,
              "MealHouse Credits",
              'account_balance_wallet',
              () {
                // TODO: Navigate to credits
              },
            ),
            _buildModernTile(
              context,
              "Gift Cards help",
              'support_agent',
              () {
                // TODO: Navigate to gift cards help
              },
            ),
          ],
        ),
      );

  Widget _buildMoreSection(ThemeData theme) => _addBorderSection(
        Column(
          children: [
            _buildSectionHeader(title: "More", theme: theme),
            _buildModernTile(
              context,
              "Choose language",
              'language',
              () {
                // TODO: Navigate to language selection
              },
            ),
            _buildModernTile(
              context,
              "About",
              'info',
              () {
                // TODO: Navigate to about
              },
            ),
            _buildModernTile(
              context,
              "Send feedback",
              'feedback',
              () {
                // TODO: Navigate to feedback
              },
            ),
            _buildModernTile(
              context,
              "Report a safety emergency",
              'warning',
              () {
                // TODO: Navigate to safety emergency
              },
            ),
            _buildModernTile(
              context,
              "Log out",
              'logout',
              () {
                UserSession().logout();
                Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
              },
            ),
          ],
        ),
      );
}
