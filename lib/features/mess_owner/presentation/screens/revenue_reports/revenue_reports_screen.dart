import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/features/order/domain/repositories/order_repository.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:meal_house/shared/widgets/mess_owner_app_navigation.dart';
import './widgets/earnings_trend_chart_widget.dart';
import './widgets/payment_methods_widget.dart';
import './widgets/revenue_kpi_cards_widget.dart';
import './widgets/revenue_period_tabs_widget.dart';
import './widgets/top_selling_thalis_widget.dart';

class RevenueReportsScreen extends StatefulWidget {
  const RevenueReportsScreen({super.key});

  @override
  State<RevenueReportsScreen> createState() => _RevenueReportsScreenState();
}

class _RevenueReportsScreenState extends State<RevenueReportsScreen>
    with TickerProviderStateMixin {
  final MessRepository _messRepository = sl<MessRepository>();
  final OrderRepository _orderRepository = sl<OrderRepository>();
  
  bool _isLoading = true;
  List<OrderModel> _allOrders = [];

  // TODO: Replace with Riverpod/Bloc for production
  int _selectedPeriodIndex = 2; // Default: Last 30 Days
  int _navIndex = 3; // Earnings tab active
  late AnimationController _contentAnimController;
  late Animation<double> _contentFadeAnimation;

  final List<String> _periods = [
    'Today',
    'Last 7 Days',
    'Last 30 Days',
    'Custom',
  ];

  // Period-based data map
  final Map<int, Map<String, dynamic>> _periodData = {};

  @override
  void initState() {
    super.initState();
    _contentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _contentFadeAnimation = CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOutCubic,
    );
    _contentAnimController.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final messes = await _messRepository.getMyMesses();
      if (messes.isNotEmpty) {
        final messId = messes.first.id;
        final orders = await _orderRepository.getMessOrders(messId!);
        _allOrders = orders.where((o) => o.status == 'Completed').toList();
        _calculatePeriodData();
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
    final last7Days = now.subtract(const Duration(days: 7));
    final last30Days = now.subtract(const Duration(days: 30));

    _periodData[0] = _aggregateOrders(_allOrders.where((o) => o.orderDate != null && o.orderDate!.isAfter(todayStart)).toList());
    _periodData[1] = _aggregateOrders(_allOrders.where((o) => o.orderDate != null && o.orderDate!.isAfter(last7Days)).toList());
    _periodData[2] = _aggregateOrders(_allOrders.where((o) => o.orderDate != null && o.orderDate!.isAfter(last30Days)).toList());
    _periodData[3] = _periodData[2]!; // Fallback for custom for now
  }

  Map<String, dynamic> _aggregateOrders(List<OrderModel> orders) {
    double totalRev = 0;
    for (var order in orders) {
      totalRev += order.totalPrice;
    }
    int count = orders.length;

    return {
      'totalRevenue': totalRev,
      'totalOrders': count,
      'revenueChange': '+0.0%', // Could calculate relative to previous period
      'ordersChange': '+0.0%',
      'dailyAvg': count > 0 ? totalRev / (orders.isNotEmpty ? 1 : 1) : 0.0,
      'isPositive': true,
    };
  }

  @override
  void dispose() {
    _contentAnimController.dispose();
    super.dispose();
  }

  void _onPeriodChanged(int index) {
    _contentAnimController.reset();
    setState(() {
      _selectedPeriodIndex = index;
      _calculatePeriodData();
    });
    _contentAnimController.forward();
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // TODO: Custom range
      _onPeriodChanged(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final isTablet = MediaQuery.of(context).size.width >= 600;
    final currentData = _periodData[_selectedPeriodIndex] ?? _periodData[2]!;

    if (isTablet) {
      return _buildTabletLayout(currentData);
    }
    return _buildPhoneLayout(currentData);
  }

  Widget _buildPhoneLayout(Map<String, dynamic> data) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Period tabs
            RevenuePeriodTabsWidget(
              periods: _periods,
              selectedIndex: _selectedPeriodIndex,
              onPeriodChanged: _onPeriodChanged,
            ),
            // Scrollable content
            Expanded(
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPI Cards
                      RevenueKpiCardsWidget(
                        totalRevenue: data['totalRevenue'] as double,
                        totalOrders: data['totalOrders'] as int,
                        revenueChange: data['revenueChange'] as String,
                        ordersChange: data['ordersChange'] as String,
                        isPositive: data['isPositive'] as bool,
                      ),
                      const SizedBox(height: 16),
                      // Earnings Trend Chart
                      EarningsTrendChartWidget(
                        selectedPeriodIndex: _selectedPeriodIndex,
                        dailyAvg: data['dailyAvg'] as double,
                        orders: _allOrders,
                      ),
                      const SizedBox(height: 16),
                      // Payment Methods
                      PaymentMethodsWidget(
                        orders: _allOrders,
                      ),
                      const SizedBox(height: 20),
                      // Top Selling Thalis Header
                      Text(
                        'Top Selling Thalis',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Top Selling Thalis List
                      TopSellingThalisWidget(
                        orders: _allOrders,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: AppNavigation(
          currentIndex: _navIndex,
          onDestinationSelected: (index) {
            if (index == 3) {
              Navigator.pushNamed(context, AppRoutes.earningsScreen);
              return;
            }
            if (index == 2) {
              Navigator.pushNamed(context, AppRoutes.menuHistoryScreen);
              return;
            }
            if (index == 4) {
              Navigator.pushNamed(context, AppRoutes.messOwnerProfileScreen);
              return;
            }
            setState(() => _navIndex = index);
          },
        ),
      ),
    );
  }

  Widget _buildTabletLayout(Map<String, dynamic> data) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Row(
          children: [
            // Navigation Rail
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: AppNavigation(
                currentIndex: _navIndex,
                onDestinationSelected: (index) {
                  // TODO: Replace with Riverpod/Bloc for production
                  setState(() => _navIndex = index);
                },
              ),
            ),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Tablet AppBar
                  _buildTabletAppBar(),
                  // Period tabs
                  RevenuePeriodTabsWidget(
                    periods: _periods,
                    selectedIndex: _selectedPeriodIndex,
                    onPeriodChanged: _onPeriodChanged,
                  ),
                  Expanded(
                    child: FadeTransition(
                      opacity: _contentFadeAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // KPI row - 2 columns on tablet
                            RevenueKpiCardsWidget(
                              totalRevenue: data['totalRevenue'] as double,
                              totalOrders: data['totalOrders'] as int,
                              revenueChange: data['revenueChange'] as String,
                              ordersChange: data['ordersChange'] as String,
                              isPositive: data['isPositive'] as bool,
                              isTablet: true,
                            ),
                            const SizedBox(height: 20),
                            // Chart + Payment Methods side by side
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: EarningsTrendChartWidget(
                                    selectedPeriodIndex: _selectedPeriodIndex,
                                    dailyAvg: data['dailyAvg'] as double,
                                    orders: _allOrders,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 4,
                                  child: PaymentMethodsWidget(
                                    orders: _allOrders,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Top Selling Thalis
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Top Selling Thalis',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TopSellingThalisWidget(
                              orders: _allOrders,
                              isTablet: true,
                            ),
                          ],
                        ),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(50),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
            size: 24,
          ),
        ),
      ),
      title: Text(
        'Revenue Reports',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      actions: [
        InkWell(
          onTap: _showDateRangePicker,
          borderRadius: BorderRadius.circular(50),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(
              Icons.calendar_month_outlined,
              color: AppTheme.textPrimary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildTabletAppBar() {
    return Container(
      height: 64,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            'Revenue Reports',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: _showDateRangePicker,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Custom Range',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
