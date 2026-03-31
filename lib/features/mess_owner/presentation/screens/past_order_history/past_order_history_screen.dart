import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:meal_house/core/theme/app_theme.dart';

class PastOrderHistoryScreen extends StatefulWidget {
  const PastOrderHistoryScreen({super.key});

  @override
  State<PastOrderHistoryScreen> createState() => _PastOrderHistoryScreenState();
}

class _PastOrderHistoryScreenState extends State<PastOrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _navIndex = 2; // History tab active

  final List<Map<String, dynamic>> _allOrders = [
    {
      'id': '#ORD-8821',
      'date': 'Oct 24, 2023 • 12:30 PM',
      'status': 'COMPLETED',
      'itemName': 'Special North Indian Thali',
      'qty': 2,
      'mealSlot': 'Lunch Slot',
      'price': '₹320',
      'image':
          'https://images.unsplash.com/photo-1480961508888-d8d6448c8b7a',
      'imageLabel':
          'North Indian thali with rice, dal, and curry in a dark bowl',
    },
    {
      'id': '#ORD-8819',
      'date': 'Oct 24, 2023 • 08:15 PM',
      'status': 'CANCELLED',
      'itemName': 'Standard Veg Thali',
      'qty': 1,
      'mealSlot': 'Dinner Slot',
      'price': '₹120',
      'image':
          'https://images.unsplash.com/photo-1594917156256-37703f0c993c',
      'imageLabel':
          'Vegetable thali with fresh vegetables and green salad in a box',
      'cancelReason': 'Customer requested cancellation due to change of plans.',
    },
    {
      'id': '#ORD-8756',
      'date': 'Oct 23, 2023 • 01:00 PM',
      'status': 'COMPLETED',
      'itemName': 'Maharaja Deluxe Thali',
      'qty': 3,
      'mealSlot': 'Lunch Slot',
      'price': '₹750',
      'image':
          'https://images.unsplash.com/photo-1680993032090-1ef7ea9b51e5',
      'imageLabel':
          'Maharaja deluxe thali with rice, multiple curries and dessert',
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    final query = _searchController.text.toLowerCase();
    final tab = _tabController.index;
    return _allOrders.where((order) {
      final matchesSearch =
          query.isEmpty ||
          order['id'].toString().toLowerCase().contains(query) ||
          order['itemName'].toString().toLowerCase().contains(query);
      final matchesTab =
          tab == 0 ||
          (tab == 1 && order['status'] == 'COMPLETED') ||
          (tab == 2 && order['status'] == 'CANCELLED');
      return matchesSearch && matchesTab;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildTabs(),
          Expanded(child: _buildOrderList()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppTheme.primary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Past Order History',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3EE),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFCCBC), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search Order ID, Thali, or Customer',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _filterChip('Date', Icons.calendar_month_outlined),
          const SizedBox(width: 10),
          _filterChip('Status', Icons.filter_alt),
          const SizedBox(width: 10),
          _filterChip('Meal Slot', Icons.access_time),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 5),
          Icon(icon, size: 16, color: AppTheme.primary),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 2.5,
            tabs: const [
              Tab(text: 'All Orders'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    final orders = _filteredOrders;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: orders.length + 1,
      itemBuilder: (context, index) {
        if (index == orders.length) {
          return _buildPagination();
        }
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isCompleted = order['status'] == 'COMPLETED';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: order ID + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['id'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                _buildStatusBadge(order['status']),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              order['date'],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Item row: image + name/qty + price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: order['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFFF5F5F5),
                      child: const Icon(
                        Icons.restaurant,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFFF5F5F5),
                      child: const Icon(
                        Icons.restaurant,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['itemName'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${order['qty']} • ${order['mealSlot']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  order['price'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            // Cancellation reason box
            if (!isCompleted && order['cancelReason'] != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Reason: ${order['cancelReason']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFFD32F2F),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Action buttons
            if (isCompleted)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      child: Text(
                        'View Receipt',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        elevation: 0,
                      ),
                      child: Text(
                        'Repeat Order',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    backgroundColor: const Color(0xFFF5F5F5),
                  ),
                  child: Text(
                    'Help & Support',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isCompleted = status == 'COMPLETED';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isCompleted
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC2185B),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            'Showing 50 of 1,240 orders',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Load More',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard_rounded,
        'label': 'Dashboard',
      },
      {
        'icon': Icons.receipt_long_outlined,
        'activeIcon': Icons.receipt_long_rounded,
        'label': 'Live Orders',
      },
      {
        'icon': Icons.history_outlined,
        'activeIcon': Icons.history_rounded,
        'label': 'History',
      },
      {
        'icon': Icons.restaurant_menu_outlined,
        'activeIcon': Icons.restaurant_menu_rounded,
        'label': 'Menu',
      },
      {
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
        'label': 'Profile',
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final isActive = index == _navIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _navIndex = index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isActive
                                ? items[index]['activeIcon'] as IconData
                                : items[index]['icon'] as IconData,
                            color: isActive
                                ? AppTheme.primary
                                : AppTheme.textMuted,
                            size: 24,
                          ),
                          if (isActive)
                            Positioned(
                              top: -2,
                              right: -4,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isActive
                              ? AppTheme.primary
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
