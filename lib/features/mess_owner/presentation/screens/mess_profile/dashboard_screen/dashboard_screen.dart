import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/features/auth/domain/repositories/auth_repository.dart';
import 'package:meal_house/features/auth/domain/entities/user.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/mess_owner/domain/models/menu_model.dart';
import 'package:meal_house/features/mess_owner/domain/models/dashboard_stats_model.dart';
import 'package:meal_house/shared/notifications/tab_change_notification.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthRepository _authRepository = sl<AuthRepository>();
  final MessRepository _messRepository = sl<MessRepository>();

  User? _user;
  MessModel? _mess;
  MenuModel? _menu;
  DashboardStatsModel? _stats; // Added DashboardStatsModel
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authRepository.getCurrentUser();
      final messes = await _messRepository.getMyMesses();
      
      if (mounted) {
        setState(() {
          _user = user;
          if (messes.isNotEmpty) {
            _mess = messes.first;
          }
        });

        if (_mess != null && _mess!.id != null) {
          try {
            final results = await Future.wait([
              _messRepository.getMenu(_mess!.id!),
              _messRepository.getDashboardStats(_mess!.id!),
            ]);

            if (mounted) {
              setState(() {
                _menu = results[0] as MenuModel;
                _stats = results[1] as DashboardStatsModel;
              });
            }
          } catch (e) {
            debugPrint('Error loading dashboard stats: $e');
          }
        }
        
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE8650A)),
      );
    }

    return Container(
      color: const Color(0xFFFAF0E6),
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFFE8650A),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildStatTiles(),
                    const SizedBox(height: 24),
                    _buildMenuStatusSection(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildPickupPointsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    String greeting = "Good Morning,";
    if (now.hour >= 12 && now.hour < 17) {
      greeting = "Good Afternoon,";
    } else if (now.hour >= 17) {
      greeting = "Good Evening,";
    }

    final initials = _mess?.name.isNotEmpty == true 
        ? _mess!.name.substring(0, 1).toUpperCase()
        : "M";

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                '$greeting ${_user?.firstName ?? ""}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _mess?.name ?? 'Complete Your Mess Setup',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8D8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF1A1A1A),
                size: 22,
              ),
            ),
            Positioned(
              top: 9,
              right: 9,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE8650A),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: (_mess?.logo != null)
                ? Image.network(
                    _mess!.logo!.startsWith('http')
                        ? _mess!.logo!
                        : 'http://localhost:5000${_mess!.logo}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTiles() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  (_stats?.totalOrders ?? 0).toString(),
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE8650A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TOTAL ORDERS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF888888),
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  (_stats?.mealsLeft ?? 0).toString(),
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE8650A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MEALS LEFT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF888888),
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8650A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '₹${_stats?.totalRevenue.toStringAsFixed(0) ?? '0'}',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'REVENUE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withAlpha(220),
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuStatusSection() {
    final breakfastItems = _menu?.items.where((i) => i.mealType.contains('Breakfast')).map((i) => i.name).join(', ') ?? '';
    final lunchItems = _menu?.items.where((i) => i.mealType.contains('Lunch')).map((i) => i.name).join(', ') ?? '';
    final dinnerItems = _menu?.items.where((i) => i.mealType.contains('Dinner')).map((i) => i.name).join(', ') ?? '';
    final extraItems = _menu?.items.where((i) => i.mealType.contains('Extra')).map((i) => i.name).join(', ') ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Menu Status",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: _loadDashboardData,
              child: Text(
                'Refresh',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE8650A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildMealCard(
          mealName: 'Breakfast',
          mealDesc: breakfastItems.isEmpty ? 'Not set' : breakfastItems,
          orders: '${_stats?.todayStats['Breakfast']?.orders ?? 0} Orders',
          remaining: '${_stats?.todayStats['Breakfast']?.pending ?? 0} left to deliver',
          remainingColor: const Color(0xFF22C55E),
          leftBorderColor: const Color(0xFFEAB308),
        ),
        const SizedBox(height: 10),
        _buildMealCard(
          mealName: 'Lunch',
          mealDesc: lunchItems.isEmpty ? 'Not set' : lunchItems,
          orders: '${_stats?.todayStats['Lunch']?.orders ?? 0} Orders',
          remaining: '${_stats?.todayStats['Lunch']?.pending ?? 0} left to deliver',
          remainingColor: Colors.red,
          leftBorderColor: const Color(0xFFE8650A),
        ),
        const SizedBox(height: 10),
        _buildMealCard(
          mealName: 'Dinner',
          mealDesc: dinnerItems.isEmpty ? 'Not set' : dinnerItems,
          orders: '${_stats?.todayStats['Dinner']?.orders ?? 0} Orders',
          remaining: '${_stats?.todayStats['Dinner']?.pending ?? 0} left to deliver',
          remainingColor: const Color(0xFF3B82F6),
          leftBorderColor: const Color(0xFF7C3AED),
        ),
        if (extraItems.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildMealCard(
            mealName: 'Extra',
            mealDesc: extraItems,
            orders: '${_stats?.todayStats['Extra']?.orders ?? 0} Orders',
            remaining: '${_stats?.todayStats['Extra']?.pending ?? 0} Pending',
            remainingColor: Colors.grey,
            leftBorderColor: const Color(0xFF6B7280),
          ),
        ],
      ],
    );
  }

  Widget _buildMealCard({
    required String mealName,
    required String mealDesc,
    required String orders,
    required String remaining,
    required Color remainingColor,
    required Color leftBorderColor,
  }) {
    return GestureDetector(
      onTap: () {
        TabChangeNotification(2, args: mealName).dispatch(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: leftBorderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mealName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              mealDesc,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            orders,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            remaining,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: remainingColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add,
                circleColor: const Color(0xFFE8650A),
                label: 'Add Menu',
                onTap: () async {
                   await Navigator.pushNamed(context, AppRoutes.addMenuItemScreen);
                   _loadDashboardData();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                icon: Icons.list_alt_outlined,
                circleColor: const Color(0xFF3B82F6),
                label: 'View Orders',
                onTap: () {
                  TabChangeNotification(1).dispatch(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                icon: Icons.format_list_numbered,
                circleColor: const Color(0xFF22C55E),
                label: 'Quantity',
                onTap: () {
                  TabChangeNotification(2).dispatch(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color circleColor,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8D5C0), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPickupPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PICKUP POINT SUMMARY',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.pickupPointOrdersScreen,
              ),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE8650A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.pickupPointOrdersScreen),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildPickupRow(
                  label: '${_mess?.name ?? "Mess"} Gate',
                  count: _stats?.todayStats['Lunch']?.orders ?? 0,
                  showDivider: true,
                ),
                _buildPickupRow(
                  label: 'External Point',
                  count: 0,
                  showDivider: true,
                ),
                _buildPickupRow(
                  label: 'Campus Hub',
                  count: 0,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupRow({
    required String label,
    required int count,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE8650A),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFFF0F0F0),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
