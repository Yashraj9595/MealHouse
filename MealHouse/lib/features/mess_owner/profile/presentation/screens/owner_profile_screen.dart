import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/core/app_export.dart';
import 'package:MealHouse/core/auth/user_session.dart';
import 'package:MealHouse/routes/app_routes.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/mess_info_card.dart';
import '../state/mess_profile_providers.dart';
import 'edit_mess_profile_screen.dart';

class OwnerProfileScreen extends ConsumerStatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  ConsumerState<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends ConsumerState<OwnerProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsyncValue = ref.watch(messProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fb),
      body: profileAsyncValue.when(
        data: (profile) => _buildProfileContent(context, theme, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ThemeData theme, dynamic profile) {
    return CustomScrollView(
      slivers: [
        _buildZomatoStyleHeader(context, theme, profile),
        SliverToBoxAdapter(child: SizedBox(height: 3.h)),
        _buildQuickActions(theme),
        SliverToBoxAdapter(child: SizedBox(height: 3.h)),
        _buildProfileSections(theme, profile),
        SliverToBoxAdapter(child: SizedBox(height: 4.h)),
      ],
    );
  }

  Widget _buildZomatoStyleHeader(BuildContext context, ThemeData theme, dynamic profile) {
    return SliverAppBar(
      expandedHeight: 28.h,
      pinned: true,
      backgroundColor: const Color(0xFFe13742),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const CustomIconWidget(iconName: AppIcons.settings, color: Colors.white),
          onPressed: () {},
        ),
      ],
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
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: const Color(0xFFe13742).withValues(alpha: 0.1),
                          backgroundImage: NetworkImage("https://api.dicebear.com/7.x/avataaars/svg?seed=Rajesh"),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFe13742),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    "Rajesh Kumar",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "rajesh.mess@example.com",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'MESS OWNER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildQuickActions(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: [
            _buildClickableIconLabel(
              label: "Edit Profile",
              iconName: 'person',
              onClick: () {},
              theme: theme,
            ),
            SizedBox(width: 3.w),
            _buildClickableIconLabel(
              label: "Mess Details",
              iconName: 'restaurant',
              onClick: () {},
              theme: theme,
            ),
            SizedBox(width: 3.w),
            _buildClickableIconLabel(
              label: "Analytics",
              iconName: 'analytics',
              onClick: () {},
              theme: theme,
            ),
          ],
        ),
      ),
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

  Widget _buildProfileSections(ThemeData theme, dynamic profile) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildSectionHeader(theme, 'Owner Details'),
          _buildZomatoStyleTile(
            'Full Name',
            'Rajesh Kumar',
            'person_outline',
            () {},
          ),
          _buildZomatoStyleTile(
            'Email Address',
            'rajesh.mess@example.com',
            'email',
            () {},
          ),
          _buildZomatoStyleTile(
            'Phone Number',
            '+91 98765 43210',
            'phone',
            () {},
          ),
          _buildZomatoStyleTile(
            'Identity Verification',
            'Verified (Aadhar Card)',
            'verified_user',
            () {},
            extraWidget: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffeaffee),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const CustomIconWidget(
                iconName: 'check_circle',
                color: Color(0xff257e3e),
                size: 16,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          _buildSectionHeader(theme, 'Mess Profile'),
          _buildZomatoStyleTile(
            'Mess Name',
            profile.messName ?? 'Rajesh Kitchen',
            'restaurant',
            () {},
          ),
          _buildZomatoStyleTile(
            'Address',
            profile.address ?? 'Koramangala, Bangalore',
            'location_on',
            () {},
          ),
          _buildZomatoStyleTile(
            'Operating Hours',
            profile.operatingHours ?? '11:00 AM - 10:00 PM',
            'schedule',
            () {},
          ),
          _buildZomatoStyleTile(
            'Cuisine Type',
            profile.isVegOnly ?? true ? 'Pure Vegetarian' : 'Vegetarian & Non-Vegetarian',
            profile.isVegOnly ?? true ? 'eco' : 'restaurant',
            () {},
            extraWidget: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: profile.isVegOnly ?? true 
                    ? const Color(0xffeaffee) 
                    : const Color(0xffffedef),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                profile.isVegOnly ?? true ? 'VEG' : 'NON-VEG',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 10,
                  color: profile.isVegOnly ?? true 
                      ? const Color(0xff257e3e) 
                      : const Color(0xFFe13742),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          _buildSectionHeader(theme, 'Photos'),
          _buildPhotoGrid(),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMessProfileScreen(profile: profile),
                  ),
                );
              },
              icon: const CustomIconWidget(iconName: AppIcons.edit, color: Colors.white),
              label: const Text("Edit Mess Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe13742),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          _buildZomatoStyleTile(
            'Logout',
            'Sign out from your account',
            'logout',
            () {
              UserSession().logout();
              Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
            },
            isLogout: true,
          ),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Container(
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
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZomatoStyleTile(
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap, {
    Widget? extraWidget,
    bool isLogout = false,
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
                    backgroundColor: isLogout 
                        ? const Color(0xFFe13742).withValues(alpha: 0.1)
                        : const Color(0xfff3f4f8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: CustomIconWidget(
                        iconName: iconName,
                        color: isLogout 
                            ? const Color(0xFFe13742)
                            : const Color(0xff9296a5),
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isLogout ? const Color(0xFFe13742) : null,
                            ),
                          ),
                          if (subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xff9296a5),
                              ),
                            ),
                        ],
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

  Widget _buildPhotoGrid() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImageWidget(
                  imageUrl: "https://picsum.photos/200/200?random=$index",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
