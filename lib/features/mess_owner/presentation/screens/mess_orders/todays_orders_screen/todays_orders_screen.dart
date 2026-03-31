import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class TodaysOrdersScreen extends StatefulWidget {
  const TodaysOrdersScreen({super.key});

  @override
  State<TodaysOrdersScreen> createState() => _TodaysOrdersScreenState();
}

class _TodaysOrdersScreenState extends State<TodaysOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentNavIndex = 0;

  final List<Map<String, dynamic>> _lunchOrders = [
    {
      'orderNumber': '#2045',
      'status': 'PREPARING',
      'foodName': 'Lunch Veg Thali',
      'quantity': '2 Items',
      'pickupTime': '1:00 PM - 2:00 PM',
      'pickupPoint': 'Office Gate',
    },
    {
      'orderNumber': '#2046',
      'status': 'PREPARING',
      'foodName': 'Special Chicken Thali',
      'quantity': '1 Item',
      'pickupTime': '1:15 PM - 2:00 PM',
      'pickupPoint': 'North Campus Hub',
    },
  ];

  final List<Map<String, dynamic>> _breakfastOrders = [];
  final List<Map<String, dynamic>> _dinnerOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(_breakfastOrders),
          _buildOrdersList(_lunchOrders),
          _buildOrdersList(_dinnerOrders),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        "Today's Orders",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A1F2E),
        ),
      ),
      centerTitle: false,
      titleSpacing: 20,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                color: AppTheme.primary,
                size: 28,
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: const Color(0xFF9CA3AF),
            indicatorColor: AppTheme.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Breakfast'),
              Tab(text: 'Lunch'),
              Tab(text: 'Dinner'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: const Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 12),
            Text(
              'No orders yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildOrderCard(orders[index]),
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order number + status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order['orderNumber'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['status'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD97706),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Food name
          Text(
            order['foodName'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1F2E),
            ),
          ),
          const SizedBox(height: 12),

          // Quantity + Pickup Time
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order['quantity'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1F2E),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Time',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order['pickupTime'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1F2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pickup Point
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pickup Point',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order['pickupPoint'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1F2E),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Marked as Preparing',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        ),
                        backgroundColor: AppTheme.navy,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Mark Preparing',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1F2E),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Marked as Ready',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        ),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Mark Ready',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildNavItem(
                0,
                Icons.help_outline,
                Icons.help_outline,
                'ORDERS',
              ),
              _buildNavItem(
                1,
                Icons.history_outlined,
                Icons.history_rounded,
                'HISTORY',
              ),
              _buildNavItem(
                2,
                Icons.settings_outlined,
                Icons.settings_rounded,
                'SETTINGS',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = _currentNavIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentNavIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppTheme.primary : Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isActive ? AppTheme.primary : Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
