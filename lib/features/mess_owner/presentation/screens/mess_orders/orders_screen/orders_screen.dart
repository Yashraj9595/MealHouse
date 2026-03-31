import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/features/order/domain/repositories/order_repository.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedStatusIndex = 0;
  
  final MessRepository _messRepository = sl<MessRepository>();
  final OrderRepository _orderRepository = sl<OrderRepository>();
  
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _messId;

  final List<String> _statusFilters = [
    'Confirmed',
    'Preparing',
    'Ready',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeOrders();
  }

  Future<void> _initializeOrders() async {
    setState(() => _isLoading = true);
    try {
      final messes = await _messRepository.getMyMesses();
      if (messes.isNotEmpty) {
        _messId = messes.first.id;
        await _fetchOrders();
      }
    } catch (e) {
      debugPrint('Error initializing orders: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchOrders() async {
    if (_messId == null) return;
    try {
      final orders = await _orderRepository.getMessOrders(_messId!);
      if (mounted) {
        setState(() {
          _orders = orders;
        });
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  Future<void> _updateStatus(String orderId, String status) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, status);
      await _fetchOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusBadgeColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xFF2D7A4F);
      case 'PREPARING':
        return AppTheme.primary;
      case 'READY':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCustomAppBar(),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : TabBarView(
                controller: _tabController,
                children: [
                  RefreshIndicator(
                    onRefresh: _fetchOrders,
                    child: _buildOrdersList('Breakfast'),
                  ),
                  RefreshIndicator(
                    onRefresh: _fetchOrders,
                    child: _buildOrdersList('Lunch'),
                  ),
                  RefreshIndicator(
                    onRefresh: _fetchOrders,
                    child: _buildOrdersList('Dinner'),
                  ),
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      color: AppTheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orders',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Icon(Icons.tune_rounded, color: AppTheme.primary, size: 26),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 2.5,
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
        ],
      ),
    );
  }

  Widget _buildOrdersList(String mealTab) {
    return Column(
      children: [
        // Status filter chips
        Container(
          color: AppTheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_statusFilters.length, (index) {
                final isSelected = _selectedStatusIndex == index;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _statusFilters.length - 1 ? 10 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatusIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : const Color(0xFFD1D5DB),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _statusFilters[index],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        // Orders list
        Expanded(
          child: _getFilteredOrders(mealTab).isEmpty
              ? _buildEmptyState(mealTab)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _getFilteredOrders(mealTab).length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildOrderCard(_getFilteredOrders(mealTab)[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<OrderModel> _getFilteredOrders(String mealTab) {
    final filter = _statusFilters[_selectedStatusIndex].toUpperCase();
    return _orders.where((order) {
      final String orderMealType = order.items.isNotEmpty ? order.items.first.mealType ?? 'Extra' : 'Extra';
      if (orderMealType != mealTab) return false;

      if (filter == 'COMPLETED') {
        return order.status.toUpperCase() == 'DELIVERED';
      }
      return order.status.toUpperCase() == filter;
    }).toList();
  }

  Widget _buildEmptyState(String mealTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No ${_statusFilters[_selectedStatusIndex]} $mealTab orders',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final status = order.status.toUpperCase();
    final badgeColor = _getStatusBadgeColor(status);
    final itemName = order.items.isNotEmpty ? order.items.first.name : 'Unknown Item';
    final qty = order.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final timeStr = order.orderDate != null ? DateFormat('hh:mm a').format(order.orderDate!) : '--:--';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.orderDetailsScreen, arguments: order);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order details
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID and Qty row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${order.id?.substring(order.id!.length - 4).toUpperCase() ?? 'UNK'}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Item name
                  Text(
                    itemName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Qty and time row
                  Row(
                    children: [
                      Text(
                        'Qty: $qty',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Action buttons
                  if (status != 'DELIVERED' && status != 'CANCELLED') ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniActionButton(
                            label: 'Prepare',
                            isActive: status == 'PREPARING',
                            activeColor: AppTheme.primary,
                            onPressed: () => _updateStatus(order.id!, 'Preparing'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMiniActionButton(
                            label: 'Ready',
                            isActive: status == 'READY',
                            activeColor: AppTheme.navy,
                            onPressed: () => _updateStatus(order.id!, 'Ready'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMiniActionButton(
                            label: 'Complete',
                            isActive: false, // Since it hides once delivered
                            activeColor: const Color(0xFF16A34A),
                            onPressed: () => _updateStatus(order.id!, 'Delivered'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniActionButton({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? activeColor : const Color(0xFFF3F4F6),
          foregroundColor: isActive ? Colors.white : const Color(0xFF4B5563),
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isActive ? activeColor : const Color(0xFFD1D5DB),
              width: 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String mealTime) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: AppTheme.textSecondary.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No $mealTime orders yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

}
