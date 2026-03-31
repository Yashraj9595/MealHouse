import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/features/order/domain/repositories/order_repository.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  int _selectedPeriod = 0; // 0=Today, 1=This Week, 2=This Month
  final List<String> _periods = ['Today', 'This Week', 'This Month'];

  final MessRepository _messRepository = sl<MessRepository>();
  final OrderRepository _orderRepository = sl<OrderRepository>();

  bool _isLoading = true;
  List<OrderModel> _allOrders = [];
  String? _messId;

  final List<Map<String, dynamic>> _periodData = [
    {
      'totalRevenue': '0',
      'badge': '-',
      'orders': '0',
      'avgValue': '0',
      'breakfast': 0.0,
      'breakfastLabel': '₹0 (0%)',
      'lunch': 0.0,
      'lunchLabel': '₹0 (0%)',
      'dinner': 0.0,
      'dinnerLabel': '₹0 (0%)',
    },
    {
      'totalRevenue': '0',
      'badge': '-',
      'orders': '0',
      'avgValue': '0',
      'breakfast': 0.0,
      'breakfastLabel': '₹0 (0%)',
      'lunch': 0.0,
      'lunchLabel': '₹0 (0%)',
      'dinner': 0.0,
      'dinnerLabel': '₹0 (0%)',
    },
    {
      'totalRevenue': '0',
      'badge': '-',
      'orders': '0',
      'avgValue': '0',
      'breakfast': 0.0,
      'breakfastLabel': '₹0 (0%)',
      'lunch': 0.0,
      'lunchLabel': '₹0 (0%)',
      'dinner': 0.0,
      'dinnerLabel': '₹0 (0%)',
    },
  ];

  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final messes = await _messRepository.getMyMesses();
      if (messes.isNotEmpty) {
        _messId = messes.first.id;
        final orders = await _orderRepository.getMessOrders(_messId!);
        _allOrders = orders.where((o) => o.status == 'Completed').toList();
        _calculatePeriodData();
        _calculateTransactions();
      }
    } catch (e) {
      debugPrint('Error fetching revenue data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculatePeriodData() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final monthStart = DateTime(now.year, now.month, 1);

    _periodData[0] = _aggregateOrders(_allOrders.where((o) => o.orderDate != null && o.orderDate!.isAfter(todayStart)).toList());
    _periodData[1] = _aggregateOrders(_allOrders.where((o) => o.orderDate != null && o.orderDate!.isAfter(weekStartDay)).toList());
    _periodData[2] = _aggregateOrders(_allOrders.where((o) => o.orderDate != null && o.orderDate!.isAfter(monthStart)).toList());
  }

  Map<String, dynamic> _aggregateOrders(List<OrderModel> orders) {
    double totalRev = 0;
    double breakfastRev = 0;
    double lunchRev = 0;
    double dinnerRev = 0;

    for (var order in orders) {
      totalRev += order.totalPrice;
      if (order.orderDate != null) {
        int hour = order.orderDate!.hour;
        if (hour < 11) {
          breakfastRev += order.totalPrice;
        } else if (hour < 16) {
          lunchRev += order.totalPrice;
        } else {
          dinnerRev += order.totalPrice;
        }
      }
    }

    int count = orders.length;
    double avgValue = count > 0 ? totalRev / count : 0;

    double breakfastPct = totalRev > 0 ? breakfastRev / totalRev : 0;
    double lunchPct = totalRev > 0 ? lunchRev / totalRev : 0;
    double dinnerPct = totalRev > 0 ? dinnerRev / totalRev : 0;

    return {
      'totalRevenue': NumberFormat('#,##0').format(totalRev),
      'badge': '-',
      'orders': count.toString(),
      'avgValue': '₹${avgValue.toStringAsFixed(0)}',
      'breakfast': breakfastPct,
      'breakfastLabel': '₹${NumberFormat('#,##0').format(breakfastRev)} (${(breakfastPct * 100).toStringAsFixed(0)}%)',
      'lunch': lunchPct,
      'lunchLabel': '₹${NumberFormat('#,##0').format(lunchRev)} (${(lunchPct * 100).toStringAsFixed(0)}%)',
      'dinner': dinnerPct,
      'dinnerLabel': '₹${NumberFormat('#,##0').format(dinnerRev)} (${(dinnerPct * 100).toStringAsFixed(0)}%)',
    };
  }

  void _calculateTransactions() {
    // Show today's recent transactions or latest 10 overall
    final sorted = List<OrderModel>.from(_allOrders)
      ..sort((a, b) => (b.orderDate ?? DateTime.now()).compareTo(a.orderDate ?? DateTime.now()));
    
    final recent = sorted.take(10).toList();
    _transactions = recent.map((order) {
      String titleText = 'Order #${order.id?.substring(0, 5) ?? 'Unknown'}';
      if (order.items.isNotEmpty) {
        titleText = order.items.first.name;
        if (order.items.length > 1) titleText += ' +${order.items.length - 1}';
      }
      return {
        'title': titleText,
        'time': order.orderDate != null ? DateFormat('hh:mm a').format(order.orderDate!) : '',
        'payment': order.paymentMethod.toUpperCase(),
        'amount': '₹${order.totalPrice}',
        'status': order.status.toUpperCase(),
        'isPending': order.status == 'Pending',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final data = _periodData[_selectedPeriod];

    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.primary,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 1.h),
                  _buildPeriodTabs(),
                  SizedBox(height: 2.h),
                  _buildHeroCard(data),
                  SizedBox(height: 2.5.h),
                  _buildRevenueBreakdown(data),
                  SizedBox(height: 2.h),
                  _buildViewDetailedReports(),
                  SizedBox(height: 2.5.h),
                  _buildTransactionsSection(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earnings',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'PERFORMANCE TRACKING',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(_periods.length, (index) {
            final isSelected = _selectedPeriod == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 2.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : const Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _periods[index],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: AppTheme.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE64A19), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL REVENUE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 0.8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹${data['totalRevenue']}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.5.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  data['badge'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Divider(color: Colors.white.withAlpha(77), thickness: 1),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              _buildHeroStat(
                icon: Icons.shopping_bag_outlined,
                label: 'ORDERS',
                value: data['orders'],
              ),
              SizedBox(width: 8.w),
              _buildHeroStat(
                icon: Icons.payments_outlined,
                label: 'AVG VALUE',
                value: data['avgValue'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: 2.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueBreakdown(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Revenue Breakdown',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'BY MEAL TYPE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              _buildMealBreakdownRow(
                label: 'BREAKFAST',
                value: data['breakfastLabel'],
                progress: data['breakfast'],
                color: const Color(0xFFFFAB91),
              ),
              SizedBox(height: 2.h),
              _buildMealBreakdownRow(
                label: 'LUNCH',
                value: data['lunchLabel'],
                progress: data['lunch'],
                color: AppTheme.primary,
              ),
              SizedBox(height: 2.h),
              _buildMealBreakdownRow(
                label: 'DINNER',
                value: data['dinnerLabel'],
                progress: data['dinner'],
                color: const Color(0xFFFF7043),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealBreakdownRow({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF0F0F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildViewDetailedReports() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.revenueReportsScreen);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View Detailed Reports',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Monthly insights & tax invoices',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'View All',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        ...List.generate(_transactions.length, (index) {
          final tx = _transactions[index];
          return Container(
            margin: EdgeInsets.only(bottom: 1.5.h),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tx['isPending']
                        ? const Color(0xFFF5F5F5)
                        : AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: tx['isPending']
                        ? AppTheme.textMuted
                        : AppTheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['title'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: tx['isPending']
                              ? AppTheme.textMuted
                              : AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        '${tx['time']} • ${tx['payment']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tx['amount'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      tx['status'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tx['isPending']
                            ? AppTheme.textMuted
                            : AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

}
