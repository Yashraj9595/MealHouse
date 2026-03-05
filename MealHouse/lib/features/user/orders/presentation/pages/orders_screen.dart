import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:MealHouse/core/app_export.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock orders data
  final List<Map<String, dynamic>> _orders = [
    {
      "id": "ORD001",
      "messName": "Annapurna Mess",
      "messImage": "https://images.unsplash.com/photo-1625398407796-82650a8c135f",
      "orderTime": DateTime.now().subtract(const Duration(hours: 2)),
      "items": [
        {"name": "Veg Thali", "quantity": 1, "price": 120.0},
        {"name": "Roti", "quantity": 2, "price": 10.0},
      ],
      "totalAmount": 140.0,
      "status": "Delivered",
      "deliveryTime": DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      "id": "ORD002",
      "messName": "Shree Krishna Mess",
      "messImage": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c",
      "orderTime": DateTime.now().subtract(const Duration(minutes: 30)),
      "items": [
        {"name": "Dal Makhani", "quantity": 1, "price": 150.0},
        {"name": "Jeera Rice", "quantity": 1, "price": 80.0},
      ],
      "totalAmount": 230.0,
      "status": "Preparing",
      "estimatedTime": DateTime.now().add(const Duration(minutes: 15)),
    },
    {
      "id": "ORD003",
      "messName": "Sagar Mess",
      "messImage": "https://images.unsplash.com/photo-1585937421612-70a008356fbe",
      "orderTime": DateTime.now().subtract(const Duration(days: 1)),
      "items": [
        {"name": "Paneer Butter Masala", "quantity": 1, "price": 180.0},
      ],
      "totalAmount": 180.0,
      "status": "Cancelled",
      "cancelReason": "Item unavailable",
    },
    {
      "id": "ORD004",
      "messName": "Annapurna Mess",
      "messImage": "https://images.unsplash.com/photo-1625398407796-82650a8c135f",
      "orderTime": DateTime.now().subtract(const Duration(days: 2)),
      "items": [
        {"name": "Chole Bhature", "quantity": 2, "price": 100.0},
      ],
      "totalAmount": 200.0,
      "status": "Delivered",
      "deliveryTime": DateTime.now().subtract(const Duration(days: 2, hours: -1)),
    },
  ];

  List<Map<String, dynamic>> _getOrdersByStatus(String status) {
    if (status == 'Active') {
      return _orders.where((o) => o['status'] == 'Preparing' || o['status'] == 'Ready').toList();
    } else if (status == 'Completed') {
      return _orders.where((o) => o['status'] == 'Delivered').toList();
    } else {
      return _orders.where((o) => o['status'] == 'Cancelled').toList();
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Orders refreshed'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fb),
      appBar: AppBar(
        backgroundColor: const Color(0xFFe13742),
        elevation: 0,
        title: Text(
          'My Orders',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList('Active'),
              _buildOrderList('Completed'),
              _buildOrderList('Cancelled'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(String status) {
    final orders = _getOrdersByStatus(status);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: AppIcons.orders,
              size: 64,
              color: AppColors.textBody.withValues(alpha: 0.3),
            ),
            SizedBox(height: 2.h),
            Text(
              'No $status orders',
              style: TextStyle(
                color: AppColors.textBody.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              status == 'Active'
                  ? 'Your active orders will appear here'
                  : status == 'Completed'
                      ? 'Your completed orders will appear here'
                      : 'Your cancelled orders will appear here',
              style: TextStyle(
                color: AppColors.textBody.withValues(alpha: 0.4),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(4.w),
        itemCount: orders.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final theme = Theme.of(context);
    final status = order['status'] as String;
    final items = order['items'] as List;

    Color statusColor;
    switch (status) {
      case 'Preparing':
        statusColor = const Color(0xff2b6ee2);
        break;
      case 'Ready':
        statusColor = const Color(0xff257e3e);
        break;
      case 'Delivered':
        statusColor = const Color(0xFFe13742);
        break;
      case 'Cancelled':
        statusColor = const Color(0xffe02b2b);
        break;
      default:
        statusColor = const Color(0xff586377);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showOrderDetails(order);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with mess info
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFe13742).withValues(alpha: 0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageWidget(
                          imageUrl: order['messImage'] as String,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['messName'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            DateFormat('dd MMM yyyy • hh:mm a').format(order['orderTime'] as DateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xff586377),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  height: 1,
                  color: const Color(0xffe6e9ef),
                ),
                SizedBox(height: 2.h),

                // Items preview
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${items.length} items',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xff586377),
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            items.map((item) => (item as Map<String, dynamic>)['name'] as String).take(2).join(', ') +
                                (items.length > 2 ? ' +${items.length - 2} more' : ''),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xff586377),
                          ),
                        ),
                        Text(
                          '₹${order['totalAmount']}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFe13742),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Status specific info
                if (status == 'Preparing' && order['estimatedTime'] != null) ...[
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: const Color(0xff2b6ee2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          size: 16,
                          color: const Color(0xff2b6ee2),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Estimated ready by ${DateFormat('hh:mm a').format(order['estimatedTime'] as DateTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xff2b6ee2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (status == 'Cancelled' && order['cancelReason'] != null) ...[
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: const Color(0xffe02b2b).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'warning',
                          size: 16,
                          color: const Color(0xffe02b2b),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Reason: ${order['cancelReason']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xffe02b2b),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action buttons
                if (status == 'Delivered') ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Re-ordering...'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            side: const BorderSide(color: Color(0xFFe13742)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Re-order',
                            style: TextStyle(color: const Color(0xFFe13742)),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showOrderDetails(order);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFe13742),
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Rate Order',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Order ID
                SizedBox(height: 1.h),
                Text(
                  'Order ID: ${order['id']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xff586377),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildOrderDetailsSheet(order),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsSheet(Map<String, dynamic> order) {
    final theme = Theme.of(context);
    final items = order['items'] as List;

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 1.h),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xffe6e9ef),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xfff5f6fb),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mess info
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: const Color(0xfff5f6fb),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFe13742).withValues(alpha: 0.1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CustomImageWidget(
                                imageUrl: order['messImage'] as String,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['messName'] as String,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Order ID: ${order['id']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xff586377),
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  DateFormat('dd MMM yyyy • hh:mm a').format(order['orderTime'] as DateTime),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xff586377),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Items
                    Text(
                      'Order Items',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    ...items.map((item) {
                      final itemMap = item as Map<String, dynamic>;
                      return Container(
                        margin: EdgeInsets.only(bottom: 1.5.h),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: const Color(0xfff5f6fb),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${itemMap['quantity']}x ${itemMap['name']}',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              '₹${(itemMap['price'] as double) * (itemMap['quantity'] as int)}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFe13742),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 2.h),
                    Container(
                      height: 1,
                      color: const Color(0xffe6e9ef),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${order['totalAmount']}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFe13742),
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
    );
  }
}
