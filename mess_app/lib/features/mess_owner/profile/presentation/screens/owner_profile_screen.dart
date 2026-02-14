import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/core/app_export.dart';
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
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 32.h,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: ProfileHeaderWidget(
                  name: "Rajesh Kumar", // TODO: Fetch from User Provider
                  email: "rajesh.mess@example.com", // TODO: Fetch from User Provider
                  imageUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=Rajesh",
                ),
              ),
              actions: [
                IconButton(
                  icon: const CustomIconWidget(iconName: AppIcons.settings, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textBody,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: "Owner Details"),
                    Tab(text: "Mess Profile"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOwnerTab(theme),
            profileAsyncValue.when(
              data: (profile) => _buildMessTab(theme, profile),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: AppIcons.profile,
            title: "Full Name",
            subtitle: "Rajesh Kumar",
            onTap: () {},
          ),
          ProfileMenuItem(
            icon: AppIcons.email,
            title: "Email Address",
            subtitle: "rajesh.mess@example.com",
            onTap: () {},
          ),
          ProfileMenuItem(
            icon: AppIcons.phone,
            title: "Phone Number",
            subtitle: "+91 98765 43210",
            onTap: () {},
          ),
          ProfileMenuItem(
            icon: AppIcons.verified,
            title: "Identity Verification",
            subtitle: "Verified (Aadhar Card)",
            trailing: const CustomIconWidget(
              iconName: AppIcons.checkGroup,
              color: AppColors.success,
              size: 20,
            ),
            onTap: () {},
          ),
          SizedBox(height: 3.h),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMessTab(ThemeData theme, dynamic profile) {
    // profile is MessProfileEntity
    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MessInfoCard(
            messName: profile.messName,
            address: profile.address,
            operatingHours: profile.operatingHours,
            isVegOnly: profile.isVegOnly,
            phoneNumber: profile.phoneNumber,
          ),
          SizedBox(height: 3.h),
          Text(
            "Mess Photos",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2.h),
          _buildPhotoGrid(), // Pass images if available
          SizedBox(height: 4.h),
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
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
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          onTap: () {
            // Logout logic
          },
        ),
      ],
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
